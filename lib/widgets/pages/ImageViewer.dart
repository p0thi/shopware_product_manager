import 'package:flutter/material.dart';
import 'package:flutter_app/models/ImageData.dart';

class ImageViewer extends StatelessWidget {
  ImageData _image;

  ImageViewer(this._image);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Bild in groß betrachten."),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            GestureDetector(
              child: _image.image ?? _image.thumbnail,
            ),
            Text("Image: ${_image.image != null}"),
            Text("Thumbnail: ${_image.thumbnail != null}"),
            Row(
              children: <Widget>[
                RaisedButton(
                  onPressed: null,
                  child: Text("Schließen"),
                ),
                RaisedButton(
                  onPressed: null,
                  child: Text("Baum"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
