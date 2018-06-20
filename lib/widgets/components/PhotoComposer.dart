import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/imageData.dart';
import 'package:flutter_app/util/Util.dart';
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
  List<Widget> generateItems() {
    List<Widget> result = new List();

    for (ImageData imageData in widget._imageDatas) {
      result.add(new Container(
        child: new Stack(
          children: <Widget>[
            Container(
              child: Card(
                child: Container(
                  child: imageData.image ?? imageData.thumbnail,
                ),
              ),
            ),
            Positioned(
              top: 1.0,
              right: 1.0,
              child: Opacity(
                child: new FloatingActionButton(
                    mini: true,
                    child: new Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        widget._imageDatas.remove(imageData);

                        widget._onImageRemoved != null
                            ? widget._onImageRemoved(imageData)
                            : null;
                      });
                    }),
                opacity: .8,
              ),
            )
          ],
        ),
      ));
    }
    result.add(new Container(
      margin: new EdgeInsets.all(10.0),
      decoration: new BoxDecoration(
        border: new Border.all(
          color: Colors.black26,
          width: 5.0,
        ),
        borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
      ),
      child: new IconButton(
        icon: new Icon(
          Icons.camera_alt,
          color: Colors.black26,
          size: 45.0,
        ),
        onPressed: () async {
          File file = await ImagePicker.pickImage(
              source: ImageSource.camera, maxWidth: 1000.0, maxHeight: 1000.0);
          Image image = new Image.memory(
            Util.cropImage(file),
            fit: BoxFit.cover,
          );
          setState(() {
            widget._imageDatas.add(new ImageData.withImage(image));
          });
        },
      ),
    ));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: new Container(
        height: 290.0,
        padding: new EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text("Bilder"),
            Container(
              height: 250.0,
              child: new GridView.count(
                children: generateItems(),
                crossAxisCount: 3,
              ),
            ),
          ],
        ),
      ),
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
      children: <Widget>[],
    );
  }
}
