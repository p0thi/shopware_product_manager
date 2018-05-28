import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/ImageData.dart';
import 'package:flutter_app/models/Product.dart';
import 'package:flutter_app/widgets/components/PhotoComposer.dart';

class CreateProductPage extends StatefulWidget {
  final int _id;
  final bool _newProduct;

  CreateProductPage(this._id, this._newProduct);

  @override
  _CreateProductPageState createState() => new _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  Product _product;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Produkt ${widget._newProduct ? "erstellen" : "bearbeiten"}"),
      ),
      body: new Material(
        child: _product != null ? new Container(
          child: new ListView(
            children: <Widget>[
              new TextField(
                controller: new TextEditingController(text: _product.name),
              ),
              new TextField(
                controller: new TextEditingController(text: _product.description),
              ),
//              new PhotoComposer()
              new PhotoComposer(_product.imageDatas, onImageRemoved: (ImageData image) {print(image.name);},),

            ],
          )
        ) : new Center(child: new CircularProgressIndicator(),),
//        child: new PhotoComposer(),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _showAlertDialog,
        tooltip: 'Delete',
        child: new Icon(Icons.delete),
      ),
    );
  }

  void _showAlertDialog(){
    showDialog(context: context, builder: (builder) {
      return new AlertDialog(
        content: new Text("Willst du das neue Produkt wirklich löschen?\nEs wurde nicht gespeichert."),
        actions: <Widget>[
          new FlatButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: new Text("Ja, Löschen!")
          ),
          new FlatButton(
              onPressed: () => Navigator.pop(context),
              child: new Text("Abbrechen")
          )
        ],
      );
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget._newProduct) {
      setState(() {
        _product = new Product();
      });
    }
    else {
      Product.fromId(widget._id).then((product) {
        setState(() {
          _product = product;
        });
      });
    }
  }
}
