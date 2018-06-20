import 'package:flutter/material.dart';
import 'package:flutter_app/models/imageData.dart';
import 'package:flutter_app/widgets/pages/ImageViewer.dart';

class ImageUnit extends StatelessWidget {
  ImageData _imageData;
  ValueChanged<ImageData> _onDelete;

  ImageUnit(this._imageData, this._onDelete);

  void deleteImage() {
    print("delete image");
    _onDelete(_imageData);
  }

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      width: 100.0,
      height: 100.0,
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
    Draggable draggable = new Draggable(
        child: container,
        data: this,
        childWhenDragging: Container(
          width: 200.0,
          height: 200.0,
          child: Card(
            color: Colors.grey,
          ),
        ),
        feedback: Opacity(
          child: container,
          opacity: .4,
        ));
    return draggable;
  }
}
