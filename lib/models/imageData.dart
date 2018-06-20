import 'package:flutter/material.dart';
import 'package:flutter_app/util/Util.dart';

class ImageData {
  static final int thumbnailSize = 140;
  String _id;
  String _name;
  String _extension;
  String _thumbnailUrl;
  Image _image;
  Image _thumbnail;

  ImageData(this._id, this._name, this._extension) {
    String hashString = "media/image/thumbnail/" +
        "${_name}_${thumbnailSize}x$thumbnailSize." +
        "$_extension";
    List<String> hashList = Util.generateMD5(hashString).split("");
    String part0 = hashList[0] + hashList[1];
    String part1 = hashList[2] + hashList[3];
    String part2 = hashList[4] + hashList[5];
    String imageUrl = "${Util.shopUrl}media/image/" +
        (part0 != "ad" ? part0 : "g0") +
        "/" +
        (part1 != "ad" ? part1 : "g0") +
        "/" +
        (part2 != "ad" ? part2 : "g0") +
        "/" +
        "${_name}_${thumbnailSize}x$thumbnailSize.$_extension";
    _thumbnailUrl = imageUrl;
    _thumbnail = new Image.network(
      _thumbnailUrl,
      fit: BoxFit.cover,
      height: 150.0,
      width: 150.0,
    );
  }

  ImageData.withThumbnail(Image thumbnail) {
    _thumbnail = thumbnail;
  }

  ImageData.withImage(Image image) {
    _image = image;
  }

  String get extension => _extension;

  String get name => _name;

  String get id => _id;

  String get thumbnailUrl => _thumbnailUrl;

  Image get image => _image;

  Image get thumbnail => _thumbnail;
}
