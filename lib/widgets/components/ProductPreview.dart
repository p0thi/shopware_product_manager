import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/imageData.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/util/AppRouter.dart';

class ProductPreview extends StatefulWidget {
  Product _product;

  ProductPreview(this._product);

  @override
  _ProductPreviewState createState() => new _ProductPreviewState();
}

class _ProductPreviewState extends State<ProductPreview> {
  String _imageUrl;
  bool _imageAvailable;

  @override
  void initState() {
    super.initState();
    _imageAvailable = widget._product.imageDatas.length != 0;
    fetchImage();
  }

  void fetchImage() {
    if (!_imageAvailable) return;
    ImageData image = widget._product.imageDatas[0];
    if (mounted)
      setState(() {
        _imageUrl = image.thumbnailUrl;
        print(_imageUrl);
      });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Center(
        child: new Text(
          widget._product.name,
          style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      subtitle: Column(
        children: <Widget>[
          new Text("Noch ${widget._product.quantity} verfügbar."),
          new Text("Reingestellt am "
              "${widget._product.releaseDate.day}."
              "${widget._product.releaseDate.month}."
              "${widget._product.releaseDate.year}"),
        ],
      ),
      leading:
          CircleAvatar(radius: 40.0, backgroundImage: NetworkImage(_imageUrl)),
      contentPadding:
          new EdgeInsets.only(top: 15.0, right: 8.0, bottom: 15.0, left: 8.0),
      trailing: PopupMenuButton<_Choice>(
          onSelected: _select,
          itemBuilder: (context) {
            return _Choice.choices.map((choice) {
              return PopupMenuItem<_Choice>(
                value: choice,
                child: Text(choice.name),
              );
            }).toList();
          }),
    );
  }

  void _select(_Choice choice) {
    switch (choice.value) {
      case 0:
        AppRouter().router().navigateTo(
            context, "/edit-product/${widget._product.id}",
            transition: TransitionType.native);
        break;
      case 1:
        AppRouter().router().navigateTo(
            context, "/duplicate-product/${widget._product.id}",
            transition: TransitionType.native);
        break;
      case 2: // TODO delete product
        break;
    }
  }
}

class _Choice {
  static List<_Choice> choices = <_Choice>[
    _Choice("Bearbeiten", 0), // edit-product
    _Choice("Duplizieren", 1), // duplicate-product
    _Choice("Löschen", 2),
  ];
  String name;
  int value;

  _Choice(this.name, this.value);
}
