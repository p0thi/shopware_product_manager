import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/imageData.dart';
import 'package:flutter_app/util/Util.dart';
import 'package:flutter_app/widgets/components/photoComposer/imageUnit.dart';
import 'package:flutter_app/widgets/components/photoComposer/trashArea.dart';
import 'package:image_picker/image_picker.dart';

class PhotoComposer extends StatefulWidget {
  List<ImageData> _imageDatas;

  PhotoComposer(this._imageDatas);

  @override
  _PhotoComposerState createState() => new _PhotoComposerState();
}

class _PhotoComposerState extends State<PhotoComposer> {
  List<Widget> _items;
  int _currentProcessingPicturesCount = 0;

  @override
  void initState() {
    super.initState();
    _items = generateItems();
  }

  List<Widget> generateItems() {
    List<Widget> result = new List();

    for (ImageData imageData in widget._imageDatas) {
      result.add(ImageUnit(imageData, (ImageData iData) {
        setState(() {
          print(widget._imageDatas.remove(iData));
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
    Container tmpContainer = Container(
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black26,
          width: 3.0,
        ),
        borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
      ),
      child: new IconButton(
        icon: new Icon(
          Icons.add_a_photo,
          color: Colors.black26,
          size: Util.relSize(context, 10.0),
        ),
        onPressed: () {
          setState(() {
            _currentProcessingPicturesCount++;
            _items = generateItems();
          });
          ImagePicker
              .pickImage(
                  source: ImageSource.camera,
                  maxWidth: 2500.0,
                  maxHeight: 2500.0)
              .then((file) {
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
              setState(() {
                _currentProcessingPicturesCount =
                    max(_currentProcessingPicturesCount - 1, 0);
                widget._imageDatas.add(
                    new ImageData.withImage(Image.memory(data) /*, file*/));
                _items = generateItems();
              });
            });

//          Image image = Image.memory(
//            Util.cropImage(file),
//            fit: BoxFit.cover,
//          );
          });
        },
      ),
    );
    result.add(tmpContainer);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          child: new Container(
            height: 250.0,
            padding: new EdgeInsets.all(8.0),
            child: Container(
              height: 250.0,
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
