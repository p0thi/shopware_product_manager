import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/ImageData.dart';
import 'package:flutter_app/models/Product.dart';
import 'package:flutter_app/util/AppRouter.dart';
import 'package:flutter_app/util/Util.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;

class ProductPreview extends StatefulWidget {
  Product _product;

  ProductPreview(this._product);

  @override
  _ProductPreviewState createState() => new _ProductPreviewState();

  Product get product => _product;
}

class _ProductPreviewState extends State<ProductPreview> {
  String _imageUrl;
  double _imageWidth = 100.0;
  bool _imageAvailable;


  @override
  void initState() {
    super.initState();
    _imageAvailable = widget.product.imageDatas.length != 0;
    fetchImage();
  }

  void fetchImage() {
    if (!_imageAvailable)
      return;
    ImageData image = widget._product.imageDatas[0];
    if (mounted)
      setState(() {
        _imageUrl = image.thumbnailUrl;
        print(_imageUrl);
      });

  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.all(5.0),
      child: new RaisedButton(
        onPressed: () => showModalBottomSheet(context: context, builder: buildModal),
        color: widget.product.quantity < 1 ? Colors.grey[200] : Colors.white,
        elevation: 1.0,
        child: new Container(
          child: new Row(
            children: <Widget>[
              new Container(
                width: _imageWidth,
                height: 100.0,
                child: new Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    _imageAvailable ? new CircularProgressIndicator() : new Center(),
                    new Card(
                      color: Colors.white,
                      child: _imageUrl != null ?
                          new Image.network(_imageUrl) :
                          _imageAvailable ? new Center() : new Text("\nKein Bild verfügbar\n"),
                    )
                  ],
                ),
                alignment: Alignment.center,
              ),
              new Expanded(
                child: new Container(
                  margin: new EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(widget.product.name,
                        style: new TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      new Text("Noch ${widget.product.quantity} verfügbar."),
                      new Text("Reingestellt am "
                          "${widget.product.releaseDate.day}."
                          "${widget.product.releaseDate.month}."
                          "${widget.product.releaseDate.year}"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildModal(BuildContext context) {
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Text(widget._product.name,
            style: new TextStyle(
              fontSize: 18.0
            ),
          ),
          new RaisedButton(
            onPressed: () => new AppRouter().router().navigateTo(context, "/edit-product/${widget.product.id}", transition: TransitionType.native),
            child: new Text("Bearbeiten"),
            color: Colors.green,
            textColor: Colors.white,
          ),
          new RaisedButton(
            onPressed: () => new AppRouter().router().navigateTo(context, "/duplicate-product/${widget.product.id}", transition: TransitionType.native),
            child: new Text("Duplizieren"),
            color: Colors.blue,
            textColor: Colors.white,
          ),
          new RaisedButton(
            onPressed: () => print("Löschen"),
            child: new Text("Löschen"),
            color: Colors.red,
            textColor: Colors.white,
          ),
          new RaisedButton(
              onPressed: () => print("Abbrechen"),
              child: new Text("Abbrechen"),
              color: Colors.white70,
              textColor: Colors.black,
          ),
        ],
      )
    );
  }
}