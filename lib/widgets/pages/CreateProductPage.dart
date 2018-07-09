import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:diKapo/models/imageData.dart';
import 'package:diKapo/models/product.dart';
import 'package:diKapo/util/Util.dart';
import 'package:diKapo/widgets/components/availabilitySelector.dart';
import 'package:diKapo/widgets/components/categorySelector/categoryTreeView.dart';
import 'package:diKapo/widgets/components/dateSelector.dart';
import 'package:diKapo/widgets/components/photoComposer/photoComposer.dart';
import 'package:diKapo/widgets/components/priceSelector.dart';
import 'package:diKapo/widgets/components/steps/customStepper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateProductPage extends StatefulWidget {
  final String _id;
  final bool _newProduct;
  Product _product;

  CreateProductPage(this._id, this._newProduct);

  factory CreateProductPage.fromProduct(Product product, bool newProduct) {
    CreateProductPage result = CreateProductPage(null, newProduct);
    result._product = product;
    return result;
  }

  @override
  _CreateProductPageState createState() => new _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  Product _product;

  bool _saving = false;
  bool changed = false;
  bool saved = false;
  double _savingPercent = .1;

  List<ImageData> _imagesToRemove = new List();
  Function _httpFunction;

  TextEditingController _titleController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  PriceSelector _priceSelector;
  CategoryTreeView _categoryTreeView;
  DateSelector _dateSelector;
  PhotoComposer _photoComposer;
  AvailabilitySelector _availabilitySelector;

  int _currentStep = 0;
  List<CustomStep> _steps;

  void inputsChanged([dynamic value]) {
    changed = true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (changed) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                      "Wirklich zurück? Nicht gespeicherte Änderungen gehen verloren."),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(saved);
                      },
                      child: Text("Ja, zurück."),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Nein. Hier bleiben."),
                    )
                  ],
                );
              });
        } else {
          Navigator.of(context).pop(saved);
        }
        return Future.value(false);
      },
      child: new Scaffold(
        appBar: new AppBar(
          title: Row(
            children: <Widget>[
              new Text(
                  "Produkt ${widget._newProduct ? "erstellen" : "bearbeiten"}"),
              Padding(
                padding: EdgeInsets.only(left: Util.relWidth(context, 2.0)),
                child: Icon(widget._newProduct ? Icons.add : Icons.edit),
              )
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            Material(
              child: _product != null
                  ? new Container(
                      padding: new EdgeInsets.all(6.0),
                      child: CustomStepper(
                          currentCustomStep: _currentStep,
                          type: CustomStepperType.vertical,
                          onCustomStepContinue: () {
                            FocusScope
                                .of(context)
                                .requestFocus(new FocusNode());
                            setState(() {
                              _steps[_currentStep].isActive = false;
                              _currentStep =
                                  min(_currentStep + 1, _steps.length - 1);
                            });
                          },
                          onCustomStepCancel: () {
                            FocusScope
                                .of(context)
                                .requestFocus(new FocusNode());
                            setState(() {
                              _currentStep = max(0, _currentStep - 1);
                            });
                          },
                          onCustomStepTapped: (index) {
                            FocusScope
                                .of(context)
                                .requestFocus(new FocusNode());
                            setState(() {
                              _currentStep = index;
                            });
                          },
                          steps: _steps))
                  : new Center(
                      child: new CircularProgressIndicator(),
                    ),
//        child: new PhotoComposer(),
            ),
            _saving
                ? Positioned.fill(
                    child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Opacity(
                          child: Container(
                            color: Colors.white,
                          ),
                          opacity: .9,
                        ),
                      ),
                      Center(
                          child: Padding(
                        padding:
                            EdgeInsets.only(top: Util.relWidth(context, 10.0)),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding:
                                  EdgeInsets.all(Util.relWidth(context, 13.0)),
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.grey,
                                value: _savingPercent,
                              ),
                            ),
                            Text("Speichern...")
                          ],
                        ),
                      )),
                    ],
                  ))
                : Container(),
          ],
        ),
        floatingActionButton: new FloatingActionButton(
          heroTag: "saveproduct",
          onPressed: () {
            if (_saving) return;
            if (_photoComposer.currentProcessingPicturesCount != 0) {
              Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Es werden noch Bilder verarbeitet..."),
                    backgroundColor: Colors.red,
                  ));
              return;
            }
            safeProduct(context);
          },
          tooltip: 'Speichern',
          child: new Icon(Icons.save),
        ),
      ),
    );
  }

  Future<int> safeMedia(ImageData imageData, SharedPreferences prefs) async {
    http.Response response = await http.post("${Util.baseApiUrl}media",
        headers: Util.httpHeaders(prefs.get("username"), prefs.get("pass")),
        body: json.encode(imageData.getShopwareObject(_titleController.text)));
    int id;
    try {
      id = json.decode(response.body)["data"]["id"];
    } catch (e) {
      print(response.body);
      return null;
    }
    return id;
  }

  void deleteMedia(int id, SharedPreferences prefs) async {
    http.Response response = await http.delete("${Util.baseApiUrl}media/$id",
        headers: Util.httpHeaders(prefs.get("username"), prefs.get("pass")));
    print(response.body);
  }

  void safeProduct(BuildContext myContext) async {
    setState(() {
      _saving = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    double percentStep =
        .85 / (_product.imageDatas.length + _imagesToRemove.length);

    List<dynamic> shopwareImages = new List();
    List<int> newUploadedImages = List();
    for (ImageData imageData in _product.imageDatas) {
      int id;
      if (imageData.image == null) {
        id = imageData.id;
      } else {
        id = await safeMedia(imageData, prefs);
        if (id != null) {
          newUploadedImages.add(id);
        }
      }
      shopwareImages.add({"mediaId": id});
      setState(() {
        _savingPercent += percentStep;
      });
    }

    for (ImageData imageData in _imagesToRemove) {
      deleteMedia(imageData.id, prefs);
      setState(() {
        _savingPercent += percentStep;
      });
    }

    Map<String, dynamic> articleBody = {
      "name": _titleController.text,
      "taxId": 1,
      "active": true,
//      "active": _availabilitySelector.isAvailable,
      "__options_images": {"replace": true},
      "images": shopwareImages,
      "categories": List.of(_categoryTreeView.activeCategories.map((category) {
        return {"id": category.id};
      })),
      "descriptionLong": _descriptionController.text.replaceAll("\n", "<br>"),
      "mainDetail": {
        "number":
            "${_product.artNr != null && _product.artNr != "" && !widget._newProduct
                ? _product.artNr
                : DateTime.now().hashCode}",
        "inStock": _availabilitySelector.quantity,
        "lastStock": true,
        "stockMin": 1,
        "active": _availabilitySelector.isAvailable,
        "releaseDate": _dateSelector.releaseDate.toIso8601String(),
        "shippingTime": "7",
        "prices": [
          {
            "customerGroupKey": "EK",
            "price": _priceSelector.price,
            "pseudoPrice": _priceSelector.hasFake
                ? _priceSelector.fakePrice
                : _priceSelector.price,
          }
        ]
      },
      "supplierId": 4
    };

    if (!widget._newProduct) {
      articleBody["id"] = _product.id;
    }
    _httpFunction(
        "${Util.baseApiUrl}articles/${widget._newProduct ? "" : _product.id}",
        headers: Util.httpHeaders(prefs.get("username"), prefs.get("pass")),
        body: json.encode(articleBody)).then(
      (http.Response response) {
        setState(() {
          _saving = false;
          saved = true;
        });
        print(response.body);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          Fluttertoast.showToast(
              msg: "Artikel erfolgreich gespeichert...",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 2);
          Navigator.of(context).pop(changed);
        } else {
          Fluttertoast.showToast(
              msg:
                  "Artikel konnte nicht gespeichert werden! Bitte erneut versuchen.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 2);
          print(json.encode(articleBody));
          for (int id in newUploadedImages) {
            deleteMedia(id, prefs);
          }
        }
        changed = false;
      },
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget._product != null) {
      setupProject(widget._product);
    } else {
      Product.fromId(widget._id).then(setupProject);
    }
  }

  void setupProject(Product product) {
    if (widget._newProduct) {
      product.id = null;
      product.imageDatas.clear();
    }
    setState(() {
      _product = product;
      _categoryTreeView = CategoryTreeView(_product.categories, inputsChanged);
      _titleController.text = _product.name;
      _descriptionController.text = _product.description;
      _priceSelector = new PriceSelector(_product.price, _product.fakePrice,
          _product.price != _product.fakePrice, inputsChanged);
      _dateSelector = DateSelector(
        inputsChanged,
        initDate: widget._newProduct ? null : _product.releaseDate,
      );
      _photoComposer = PhotoComposer(
        _product,
        inputsChanged,
        onImageRemoved: (imageData) {
          _imagesToRemove.add(imageData);
          _product.imageDatas.remove(imageData);
        },
      );
      _availabilitySelector = new AvailabilitySelector(
          widget._newProduct ? true : _product.isActive,
          widget._newProduct ? 1 : _product.quantity,
          inputsChanged);
      _httpFunction = widget._newProduct ? http.post : http.put;

      _steps = <CustomStep>[
        CustomStep(
          title: Text("Bilder"),
          content: _photoComposer,
        ),
        CustomStep(
          title: Text("Titel"),
          content: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new TextField(
                style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                controller: _titleController,
                onChanged: inputsChanged,
              ),
            ),
          ),
        ),
        CustomStep(
          title: Text("Beschreibung"),
          content: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new TextField(
                maxLines: null,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
                controller: _descriptionController,
                autocorrect: true,
                onChanged: inputsChanged,
              ),
            ),
          ),
        ),
        CustomStep(
          title: Text("Kategorie"),
          content: _categoryTreeView,
        ),
        CustomStep(
          title: Text("Verfügbarkeit"),
          content: _availabilitySelector,
        ),
        CustomStep(
          title: Text("Preis"),
          content: _priceSelector,
        ),
        CustomStep(
          title: Text("Datum"),
          content: _dateSelector,
        ),
      ];
    });
  }
}
