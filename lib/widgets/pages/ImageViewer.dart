import 'package:flutter/material.dart';
import 'package:flutter_app/models/imageData.dart';
import 'package:zoomable_image/zoomable_image.dart';

class ImageViewer extends StatefulWidget {
  ImageData _image;

  ImageViewer(this._image);
  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  Image _image;

  @override
  void initState() {
    super.initState();
    _image = widget._image.image ?? widget._image.thumbnail;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Bild in groß betrachten."),
      ),
      body: Container(
        child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Material(
                child: Container(
                  child: ZoomableImage(
                    _image.image,
                    backgroundColor: Colors.white70,
                    maxScale: 3.0,
                  ),
                ),
              ),
            ),
            Text("Image: ${widget._image.image != null}"),
            Text("Thumbnail: ${widget._image.thumbnail != null}"),
            Row(
              children: <Widget>[
                RaisedButton(
                  onPressed: () => Navigator.pop(context),
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
