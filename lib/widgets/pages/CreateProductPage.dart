import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:diKapo/models/imageData.dart';
import 'package:diKapo/models/product.dart';
import 'package:diKapo/util/Util.dart';
import 'package:diKapo/widgets/components/categorySelector/categoryTreeView.dart';
import 'package:diKapo/widgets/components/dateSelector.dart';
import 'package:diKapo/widgets/components/photoComposer/photoComposer.dart';
import 'package:diKapo/widgets/components/priceSelector.dart';
import 'package:diKapo/widgets/components/steps/customStepper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateProductPage extends StatefulWidget {
  final String _id;
  final bool _newProduct;

  CreateProductPage(this._id, this._newProduct);

  @override
  _CreateProductPageState createState() => new _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final GlobalKey<ScaffoldState> widgetKey = GlobalKey();
  Product _product;

  bool _saving = false;
  double _savingPercent = .1;

  List<ImageData> _imagedToRemove = new List();
  Function _httpFunction;

  TextEditingController _titleController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  PriceSelector _priceSelector;
  CategoryTreeView _categoryTreeView;
  DateSelector _dateSelector;
  PhotoComposer _photoComposer;

  int _currentStep = 0;
  List<CustomStep> _steps;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: widgetKey,
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
                          FocusScope.of(context).requestFocus(new FocusNode());
                          setState(() {
                            _steps[_currentStep].isActive = false;
                            _currentStep =
                                min(_currentStep + 1, _steps.length - 1);
                          });
                        },
                        onCustomStepCancel: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          setState(() {
                            _currentStep = max(0, _currentStep - 1);
                          });
                        },
                        onCustomStepTapped: (index) {
                          FocusScope.of(context).requestFocus(new FocusNode());
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
          safeProduct(context);
        },
        tooltip: 'Delete',
        child: new Icon(Icons.save),
      ),
    );
  }

  Future<int> safeMedia(ImageData imageData, SharedPreferences prefs) async {
    http.Response response = await http.post("${Util.baseApiUrl}media",
        headers: Util.httpHeaders(prefs.get("username"), prefs.get("pass")),
        body: json.encode(imageData.getShopwareObject(_product.name)));
    int id = json.decode(response.body)["data"]["id"];
    return id;
  }

  void deleteMedia(ImageData imageData, SharedPreferences prefs) async {
    http.Response response = await http.delete(
        "${Util.baseApiUrl}media/${imageData.id}",
        headers: Util.httpHeaders(prefs.get("username"), prefs.get("pass")));
    print("Deleting media ${imageData.id}");
    print(response.body);
  }

  void safeProduct(BuildContext myContext) async {
    setState(() {
      _saving = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    double percentStep =
        .85 / (_product.imageDatas.length + _imagedToRemove.length);
    print(_product.imageDatas.length);
    print(_imagedToRemove.length);

//    setState(() {
//      _saving = false;
//    });
//    return;

    List<dynamic> shopwareImages = new List();
    for (ImageData imageData in _product.imageDatas) {
      int id;
      if (imageData.image == null) {
        id = imageData.id;
      } else {
        id = await safeMedia(imageData, prefs);
      }
      shopwareImages.add({"mediaId": id});
      setState(() {
        _savingPercent += percentStep;
      });
    }

    for (ImageData imageData in _imagedToRemove) {
      deleteMedia(imageData, prefs);
      setState(() {
        _savingPercent += percentStep;
      });
    }

    Map<String, dynamic> articleBody = {
      "name": _titleController.text,
      "descriptionLong": _descriptionController.text.replaceAll("\n", "<br>"),
      "taxId": 1,
      "active": true,
      "__options_images": {"replace": true},
      "images": shopwareImages,
      "categories": List.of(_categoryTreeView.activeCategories.map((category) {
        return {"id": category.id};
      })),
      "mainDetail": {
        "number": "${DateTime.now().hashCode}",
        "inStock": 1,
        "lastStock": true,
        "active": true,
        "releaseDate": _dateSelector.releaseDate.toIso8601String(),
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
      (response) {
        print(response.body);
        setState(() {
          _saving = false;
        });
//        widgetKey.currentState.widget;
        widgetKey.currentState.showSnackBar(
            SnackBar(content: Text("Artikel erfolgreich gespeichert...")));
//        Scaffold.of(myContext).showSnackBar(
//            SnackBar(content: Text("Artikel erfolgreich gespeichert...")));
//        Navigator.of(myContext).pop();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Product.fromId(widget._id).then((Product product) {
      if (widget._newProduct) {
        product.id = null;
        product.imageDatas.clear();
      }
      setState(() {
        _product = product;
        _categoryTreeView = CategoryTreeView(_product.categories);
        _titleController.text = _product.name;
        _descriptionController.text = _product.description;
        _priceSelector =
            new PriceSelector(_product.price, _product.fakePrice, true);
        _dateSelector = DateSelector(
          initDate: widget._newProduct ? null : _product.releaseDate,
        );
        _photoComposer = PhotoComposer(
          _product,
          onImageRemoved: (imageData) {
            _imagedToRemove.add(imageData);
          },
        );
        _httpFunction = widget._newProduct ? http.post : http.put;

        _steps = <CustomStep>[
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
                ),
              ),
            ),
          ),
          CustomStep(
            title: Text("Bilder"),
            content: _photoComposer,
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
                ),
              ),
            ),
          ),
          CustomStep(
            title: Text("Kategorie"),
            content: _categoryTreeView,
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
    });
  }
}
