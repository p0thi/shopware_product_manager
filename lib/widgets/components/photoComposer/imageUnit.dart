import 'package:diKapo/models/imageData.dart';
import 'package:diKapo/util/Util.dart';
import 'package:diKapo/widgets/pages/ImageViewer.dart';
import 'package:flutter/material.dart';

class ImageUnit extends StatelessWidget {
  ImageData _imageData;
  ValueChanged<ImageData> _onDelete;
  ValueChanged<ImageData> _imageDataDropped;

  ImageUnit(this._imageData, this._onDelete, this._imageDataDropped);

  void deleteImage() {
    _onDelete(_imageData);
  }

  ImageData get imageData => _imageData;

  @override
  Widget build(BuildContext context) {
    double imageWidth = Util.relWidth(context, 22.0);
    Widget container = Container(
      width: imageWidth,
      height: imageWidth,
//      width: 100.0,
//      height: 100.0,
      child: Card(
        elevation: 3.0,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) =>
                        new ImageViewer(_imageData)));
          },
          child: _imageData.image ?? _imageData.thumbnail,
        ),
      ),
    );
    Widget result = DragTarget(onAccept: (value) {
      _imageDataDropped(value.imageData);
    }, onWillAccept: (value) {
      return value != this && value is ImageUnit;
    }, builder: (context, accept, reject) {
      Draggable draggable = Draggable(
          child: container,
          data: this,
          childWhenDragging: Container(
//            width: 200.0,
//            height: 200.0,
            child: Card(
              color: Colors.grey,
            ),
          ),
          feedback: Opacity(
            child: container,
            opacity: .4,
          ));
      if (accept.length == 0 && reject.length == 0) {
        return draggable;
      } else {
        return Stack(
          children: <Widget>[
            draggable,
            Positioned(
              child: Container(
                color: Theme.of(context).accentColor,
                width: 3.0,
              ),
            ),
          ],
        );
      }
    });
    return result;
  }
}
