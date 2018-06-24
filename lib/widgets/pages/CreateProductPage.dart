import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/imageData.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/util/Util.dart';
import 'package:flutter_app/widgets/components/categoryTreeView.dart';
import 'package:flutter_app/widgets/components/photoComposer/photoComposer.dart';
import 'package:flutter_app/widgets/components/priceSelector.dart';
import 'package:flutter_app/widgets/components/steps/customStepper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateProductPage extends StatefulWidget {
  final int _id;
  final bool _newProduct;

  CreateProductPage(this._id, this._newProduct);

  @override
  _CreateProductPageState createState() => new _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  Product _product;
  TextEditingController _titleController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  PriceSelector _priceSelector;
  CategoryTreeView _categoryTreeView;
  int _currentStep = 0;
  List<CustomStep> _steps;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
            "Produkt ${widget._newProduct ? "erstellen" : "bearbeiten"}"),
      ),
      body: new Material(
        child: _product != null
            ? new Container(
                padding: new EdgeInsets.all(6.0),
                child: CustomStepper(
                    currentCustomStep: _currentStep,
                    type: CustomStepperType.vertical,
                    onCustomStepContinue: () {
                      setState(() {
                        _steps[_currentStep].isActive = false;
                        _currentStep = min(_currentStep + 1, _steps.length - 1);
                      });
                    },
                    onCustomStepCancel: () {
                      setState(() {
                        _currentStep = max(0, _currentStep - 1);
                      });
                    },
                    onCustomStepTapped: (index) {
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
      floatingActionButton: new FloatingActionButton(
        heroTag: "saveproduct",
        onPressed: safeProduct,
        tooltip: 'Delete',
        child: new Icon(Icons.save),
      ),
    );
  }

  void safeProduct() {
    List<dynamic> shopwareImages = new List();
    for (ImageData imageData in _product.imageDatas) {
      shopwareImages.add(imageData.getShopwareObject(_titleController.text));
    }
    String articleBody = json.encode({
      "name": _titleController.text,
      "descriptionLong": _descriptionController.text,
      "taxId": 1,
      "active": true,
      "images": shopwareImages,
      "categories": List.of(_categoryTreeView.activeCategories.map((category) {
        return {"id": category.id};
      })),
      "mainDetail": {
        "number": "${DateTime.now().hashCode}",
        "inStock": 1,
        "lastStock": true,
        "active": true,
        "releaseDate": DateTime.now().toIso8601String(),
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
    });

    SharedPreferences.getInstance().then((prefs) {
      http
          .post("${Util.baseApiUrl}articles",
              headers:
                  Util.httpHeaders(prefs.get("username"), prefs.get("pass")),
              body: articleBody)
          .then(
        (response) {
          print(response.body);
          Navigator.of(context).pop();
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    Product.fromId(widget._id).then((Product product) {
      if (widget._newProduct) {
        product.id = null;
      }
      setState(() {
        _product = product;
        _categoryTreeView = CategoryTreeView(_product.categories);
        _titleController.text = _product.name;
        _descriptionController.text = _product.description;
        _priceSelector =
            new PriceSelector(_product.price, _product.fakePrice, true);

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
            content: new PhotoComposer(
              _product.imageDatas,
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
                ),
              ),
            ),
          ),
          CustomStep(
            title: Text("Modell"),
            content: _categoryTreeView,
          ),
          CustomStep(
            title: Text("Preis"),
            content: _priceSelector,
          ),
        ];
      });
    });
  }
}
