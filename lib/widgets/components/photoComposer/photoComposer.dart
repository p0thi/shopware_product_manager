import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/imageData.dart';
import 'package:flutter_app/util/Util.dart';
import 'package:flutter_app/widgets/components/photoComposer/imageUnit.dart';
import 'package:flutter_app/widgets/components/photoComposer/trashArea.dart';
import 'package:image_picker/image_picker.dart';

class PhotoComposer extends StatefulWidget {
  List<ImageData> _imageDatas;
  Function _onImageRemoved;

  PhotoComposer(this._imageDatas, {Function onImageRemoved(ImageData image)}) {
    _onImageRemoved = onImageRemoved;
  }

  @override
  _PhotoComposerState createState() => new _PhotoComposerState();
}

class _PhotoComposerState extends State<PhotoComposer> {
  List<Widget> _items;

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
    result.add(new Container(
      margin: new EdgeInsets.all(10.0),
      decoration: new BoxDecoration(
        border: new Border.all(
          color: Colors.black26,
          width: 3.0,
        ),
        borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
      ),
      child: new IconButton(
        icon: new Icon(
          Icons.add_a_photo,
          color: Colors.black26,
          size: 45.0,
        ),
        onPressed: () async {
          setState(() {
            _items.add(Container(
              width: 200.0,
              height: 200.0,
              child: Card(
                child: CircularProgressIndicator(),
              ),
            ));
          });
          File file = await ImagePicker.pickImage(
              source: ImageSource.camera, maxWidth: 1000.0, maxHeight: 1000.0);
          Image image = new Image.memory(
            Util.cropImage(file),
            fit: BoxFit.cover,
          );
          setState(() {
            widget._imageDatas.add(new ImageData.withImage(image));
            _items = generateItems();
          });
        },
      ),
    ));
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
