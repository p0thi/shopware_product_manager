import 'package:flutter/material.dart';
import 'package:flutter_app/models/imageData.dart';
import 'package:flutter_app/models/product.dart';
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
        title: new Text(
            "Produkt ${widget._newProduct ? "erstellen" : "bearbeiten"}"),
      ),
      body: new Material(
        child: _product != null
            ? new Container(
                color: Colors.black12,
                padding: new EdgeInsets.all(6.0),
                child: new Column(children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new TextField(
                        decoration: InputDecoration(labelText: "Titel"),
                        style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                        controller:
                            new TextEditingController(text: _product.name),
                      ),
                    ),
                  ),
                  new PhotoComposer(
                    _product.imageDatas,
                    onImageRemoved: (ImageData image) {
                      print(image.name);
                    },
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new TextField(
                        decoration: InputDecoration(labelText: "Beschreibung"),
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                        controller: new TextEditingController(
                            text: _product.description),
                      ),
                    ),
                  ),
                  Card(
                      child: Container(
                    padding: new EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Chip(
                          label: Text("Nordwind"),
                        ),
                      ],
                    ),
                  )),
                ]))
            : new Center(
                child: new CircularProgressIndicator(),
              ),
//        child: new PhotoComposer(),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _showAlertDialog,
        tooltip: 'Delete',
        child: new Icon(Icons.delete),
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
      });
    });
  }
}
