import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/imageData.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/widgets/components/activatableChip.dart';
import 'package:flutter_app/widgets/components/photoComposer/PhotoComposer.dart';
import 'package:flutter_app/widgets/components/steps/customStepper.dart';

class CreateProductPage extends StatefulWidget {
  final int _id;
  final bool _newProduct;

  CreateProductPage(this._id, this._newProduct);

  @override
  _CreateProductPageState createState() => new _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  Product _product;
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
        onPressed: _showAlertDialog,
        tooltip: 'Delete',
        child: new Icon(Icons.save),
      ),
    );
  }

  void _showAlertDialog() {
    showDialog(
        context: context,
        builder: (builder) {
          return new AlertDialog(
            content: new Text(
                "Willst du das neue Produkt wirklich löschen?\nEs wurde nicht gespeichert."),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: new Text("Ja, Löschen!")),
              new FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: new Text("Abbrechen"))
            ],
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
                  controller: new TextEditingController(text: _product.name),
                ),
              ),
            ),
          ),
          CustomStep(
            title: Text("Bilder"),
            content: new PhotoComposer(
              _product.imageDatas,
              onImageRemoved: (ImageData image) {
                print(image.name);
              },
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
                  controller:
                      new TextEditingController(text: _product.description),
                ),
              ),
            ),
          ),
          CustomStep(
            title: Text("Modell"),
            content: Card(
                child: Container(
              padding: new EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  new ActivatableChip(
                    label: Text("Nordwind"),
                  ),
                ],
              ),
            )),
          ),
          CustomStep(
            title: Text("Title 5"),
            content: Text("Content 5"),
          ),
          CustomStep(
            title: Text("Title 6"),
            content: Text("Content 6"),
          ),
        ];
      });
    });
  }
}
