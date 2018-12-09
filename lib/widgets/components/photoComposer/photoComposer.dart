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
import 'package:flutter_native_image/flutter_native_image.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class PhotoComposer extends StatefulWidget {
  Product _product;
  ValueChanged<ImageData> _onImageDataRemoved;
  int _currentProcessingPicturesCount = 0;
  Function _inputChanged;

  int get currentProcessingPicturesCount => _currentProcessingPicturesCount;

  PhotoComposer(this._product, this._inputChanged,
      {@required ValueChanged<ImageData> onImageRemoved}) {
    this._onImageDataRemoved = onImageRemoved;
  }

  @override
  _PhotoComposerState createState() => new _PhotoComposerState();
}

class _PhotoComposerState extends State<PhotoComposer> {
  List<Widget> _items;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> generateItems() {
    List<Widget> result = new List();

    for (ImageData imageData in widget._product.imageDatas) {
      result.add(ImageUnit(imageData, (ImageData iData) {
        setState(() {
          widget._onImageDataRemoved(iData);
          widget._product.imageDatas.remove(iData);
          _items = generateItems();
          widget._inputChanged();
        });
      }, (myImageData) {
        setState(() {
          if (widget._product.imageDatas.remove(myImageData)) {
            widget._product.imageDatas.insert(
                widget._product.imageDatas.indexOf(imageData), myImageData);
            widget._inputChanged();
          }
          _items = generateItems();
        });
      }));
    }
    for (var i = 0; i < widget._currentProcessingPicturesCount; i++) {
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
              ImagePicker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 2500.0,
                      maxHeight: 2500.0)
                  .then((file) {
                setState(() {
                  widget._currentProcessingPicturesCount++;
                  _items = generateItems();
                  widget._inputChanged();
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
                ImagePicker.pickImage(
                  source: ImageSource.gallery,
//                        maxWidth: 2000.0,
//                        maxHeight: 2000.0
                ).then((file) {
                  setState(() {
                    widget._currentProcessingPicturesCount++;
                    _items = generateItems();
                    widget._inputChanged();
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
        widget._currentProcessingPicturesCount =
            max(widget._currentProcessingPicturesCount - 1, 0);
        _items = generateItems();
        widget._inputChanged();
        Util.showCustomError(context, "Es wurde kein Bild aufgenommen...");
//        Scaffold.of(context).showSnackBar(SnackBar(
//            backgroundColor: Colors.red,
//            duration: Duration(seconds: 5),
//            content: Text("Es wurde kein Bild aufgenommen...")));
      });
      return;
    }
    Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 5),
        content: Text("Das Bild wird verarbeitet...")));

    try {
      ImageCropper.cropImage(
              sourcePath: file.path,
              ratioX: 1,
              ratioY: 1,
              maxWidth: 900,
              maxHeight: 900,
              toolbarTitle: "Bild bearbeiten",
              toolbarColor: Theme.of(context).accentColor)
          .then((croppedFile) {
//      FlutterNativeImage.getImageProperties(file.path).then((properties) {
        FlutterNativeImage.getImageProperties(croppedFile.path)
            .then((properties) {
//        FlutterNativeImage.compressImage(file.path, quality: 70)
          FlutterNativeImage.compressImage(croppedFile.path, quality: 70)
              .then((lowQualityFile) {
            setState(() {
              widget._currentProcessingPicturesCount =
                  max(widget._currentProcessingPicturesCount - 1, 0);
              widget._product.imageDatas
//                  .add(new ImageData.withImage(file));
                  .add(new ImageData.withImage(croppedFile));
              _items = generateItems();
              widget._inputChanged();
            });
          });
        });
      }).catchError((error) {
        setState(() {
          widget._currentProcessingPicturesCount =
              max(widget._currentProcessingPicturesCount - 1, 0);
        });
        Util.showCustomError(context, "Das Bild wurde nicht hinzugefügt!");
      });
      Util.schowGeneralToast(
          context, "Hier den Ausschnitt des Bildes festlegen.");
//      Util.cropImageNative(file.path).then((file) {
//        setState(() {
//          widget._currentProcessingPicturesCount =
//              max(widget._currentProcessingPicturesCount - 1, 0);
//          widget._product.imageDatas.add(new ImageData.withImage(file));
//          _items = generateItems();
//          widget._inputChanged();
//        });
//      });
    } catch (e) {}
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
              height: ((_items.length - 1) ~/ 3 + 1) *
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
