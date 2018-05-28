import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/ImageData.dart';
import 'package:flutter_app/util/AppRouter.dart';
import 'package:flutter_app/util/Util.dart';
import 'package:flutter_app/widgets/pages/ImageViewer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;


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

  List<Widget> generateItems() {
    List<Widget> result = new List();

    for (ImageData imageData in widget._imageDatas) {
      result.add(new Container(
        child: new Stack(
          alignment: AlignmentDirectional.topEnd,
          children: <Widget>[
            FlatButton(
              onPressed: () => Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new ImageViewer(imageData))),
              child: Card(
                child: imageData.image ?? imageData.thumbnail,
              ),
            ),
            new IconButton(icon: new Icon(Icons.clear, color: Colors.red,), onPressed: () {
              setState(() {
                widget._imageDatas.remove(imageData);

                widget._onImageRemoved != null ? widget._onImageRemoved(imageData) : null;
              });
            })
          ],
        ),
      ));
    }
    result.add(
      new Container(
        margin: new EdgeInsets.all(10.0),
        decoration: new BoxDecoration(
          border: new Border.all(color: Colors.black26, width: 3.0,),
          borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
        ),
        child: new IconButton(
          icon: new Icon(Icons.camera_alt, color: Colors.black26,),
          onPressed: () async{
            File file = await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 1000.0, maxHeight: 1000.0);
            Image image = new Image.memory(Util.cropImage(file));
            setState(() {
              widget._imageDatas.add(new ImageData.withImage(image));
            });
          },
        ),
      )
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 150.0,
      child: new ListView(
        children: generateItems(),
        scrollDirection: Axis.horizontal,
      )
    );
  }
}

class ImageDraggable extends StatefulWidget {

  @override
  _ImageDraggableState createState() => new _ImageDraggableState();
}

class _ImageDraggableState extends State<ImageDraggable> {
  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[

      ],
    );
  }
}

