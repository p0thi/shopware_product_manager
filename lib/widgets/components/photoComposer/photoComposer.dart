import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:diKapo/models/imageData.dart';
import 'package:diKapo/models/product.dart';
import 'package:diKapo/util/Util.dart';
import 'package:diKapo/widgets/components/photoComposer/imageUnit.dart';
import 'package:diKapo/widgets/components/photoComposer/trashArea.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoComposer extends StatefulWidget {
  Product _product;
  ValueChanged<ImageData> _onImageDataRemoved;

  PhotoComposer(this._product,
      {@required ValueChanged<ImageData> onImageRemoved}) {
    this._onImageDataRemoved = onImageRemoved;
  }

  @override
  _PhotoComposerState createState() => new _PhotoComposerState();
}

class _PhotoComposerState extends State<PhotoComposer> {
  List<Widget> _items;
  int _currentProcessingPicturesCount = 0;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> generateItems() {
    List<Widget> result = new List();

    for (ImageData imageData in widget._product.imageDatas) {
      result.add(ImageUnit(imageData, (ImageData iData) {
        setState(() {
          print(widget._product.imageDatas.remove(iData));
          widget._onImageDataRemoved(iData);
          _items = generateItems();
        });
      }));
    }
    for (var i = 0; i < _currentProcessingPicturesCount; i++) {
      result.add(Container(
        width: 200.0,
        height: 200.0,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ));
    }
    double verticalPadding = Util.relHeight(context, .5);
    double horizontalPadding = Util.relWidth(context, 6.0);
    Container tmpContainer = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            child: Container(
              padding: EdgeInsets.only(
                top: verticalPadding,
                bottom: verticalPadding,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black26,
                  width: 3.0,
                ),
                borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
              ),
              child: Container(
                margin: EdgeInsets.only(
                    left: horizontalPadding, right: horizontalPadding),
                child: new Icon(
                  Icons.add_a_photo,
                  color: Colors.black26,
                  size: Util.relHeight(context, 4.0),
                ),
              ),
            ),
            onTap: () {
              ImagePicker
                  .pickImage(
                      source: ImageSource.camera,
                      maxWidth: 2500.0,
                      maxHeight: 2500.0)
                  .then((file) {
                setState(() {
                  _currentProcessingPicturesCount++;
                  _items = generateItems();
                });
                _processImage(context, file);
              });
            },
          ),
          GestureDetector(
              child: Container(
                padding: EdgeInsets.only(
                  top: verticalPadding,
                  bottom: verticalPadding,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black26,
                    width: 3.0,
                  ),
                  borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
                ),
                child: Container(
                  margin: EdgeInsets.only(
                      right: horizontalPadding, left: horizontalPadding),
                  child: new Icon(
                    Icons.image,
                    color: Colors.black26,
                    size: Util.relHeight(context, 4.0),
                  ),
                ),
              ),
              onTap: () {
                ImagePicker
                    .pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 2500.0,
                        maxHeight: 2500.0)
                    .then((file) {
                  setState(() {
                    _currentProcessingPicturesCount++;
                    _items = generateItems();
                  });
                  _processImage(context, file);
                });
              }),
        ],
      ),
    );
    result.add(tmpContainer);
    return result;
  }

  void _processImage(BuildContext context, File file) {
    if (file == null) {
      setState(() {
        _currentProcessingPicturesCount =
            max(_currentProcessingPicturesCount - 1, 0);
        _items = generateItems();
        Scaffold.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            content: Text("Es wurde kein Bild aufgenommen...")));
      });
      return;
    }
    Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 5),
        content: Text("Das Bild wird verarbeitet...")));

    compute(Util.cropImage, file.path).then((data) {
      List<int> bytes = base64Decode(data);
      setState(() {
        _currentProcessingPicturesCount =
            max(_currentProcessingPicturesCount - 1, 0);
        widget._product.imageDatas.add(new ImageData.withImage(
            Image.memory(
              bytes,
            ),
            data));
        _items = generateItems();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _items = generateItems();
    });
    return Column(
      children: <Widget>[
        Card(
          child: new Container(
//            height: ((1 / 4 * _items.length).toInt() + 1) * 200.0,
            padding: new EdgeInsets.all(8.0),
            child: Container(
              height: ((1 / 4 * _items.length).toInt() + 1) *
                  Util.relHeight(context, 14.0),
              child: new GridView.count(
                children: _items,
                crossAxisCount: 3,
              ),
            ),
          ),
        ),
        new TrashArea(),
      ],
    );
  }
}
