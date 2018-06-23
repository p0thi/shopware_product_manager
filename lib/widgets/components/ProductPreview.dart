import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/imageData.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/util/AppRouter.dart';
import 'package:flutter_app/util/Util.dart';

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
//          CircleAvatar(radius: 40.0, backgroundImage: NetworkImage(_imageUrl)),
          Container(
        width: 80.0,
        height: 80.0,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(_imageUrl), fit: BoxFit.cover),
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
            border: Border.all(
                width: Util.getWidthPercentage(context, .7),
                color: Colors.green)),
      ),
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
        },
      ),
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

class ProductPreviewPlaceholder extends StatelessWidget {
  Widget getTextPlaceholder(double height) {
    return Container(
      margin: EdgeInsets.all(3.0),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(50.0)),
        color: Colors.grey[500],
        child: Container(
          height: height,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: .2,
          child: ListTile(
            title: Center(
              child: getTextPlaceholder(17.5),
            ),
            subtitle: Column(
              children: <Widget>[
                getTextPlaceholder(12.5),
                getTextPlaceholder(12.5)
              ],
            ),
            leading: CircleAvatar(
              radius: 40.0,
              backgroundColor: Colors.grey[500],
            ),
            contentPadding: new EdgeInsets.only(
                top: 15.0, right: 8.0, bottom: 15.0, left: 8.0),
            trailing: PopupMenuButton<_Choice>(
//          onSelected: _select,
                itemBuilder: (context) {}),
          ),
        ),
        Positioned.fill(
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: CircularProgressIndicator(),
          )),
        ),
      ],
    );
  }
}
