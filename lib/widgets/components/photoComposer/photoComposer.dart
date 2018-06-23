import 'dart:isolate';

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
          size: Util.getWidthPercentage(context, 10.0),
        ),
        onPressed: () {
          List<Widget> temp = List<Widget>.from(_items);
          temp.insert(
              temp.length - 1,
              Container(
                width: 200.0,
                height: 200.0,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ));
          setState(() {
            _items = temp;
          });
          ImagePicker
              .pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1000.0,
                  maxHeight: 1000.0)
              .then((file) {
            if (file == null) {
              setState(() {
                _items = generateItems();
              });
              return;
            }
            Image image = new Image.file(file, fit: BoxFit.cover);
//          Image image = Image.memory(
//            Util.cropImage(file),
//            fit: BoxFit.cover,
//          );

            setState(() {
              widget._imageDatas.add(new ImageData.withImage(image, file));
              _items = generateItems();
            });
          });
        },
      ),
    ));
    ReceivePort receivePort = new ReceivePort();
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
