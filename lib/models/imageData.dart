import 'dart:io';

import 'package:diKapo/util/Util.dart';
import 'package:flutter/material.dart';

class ImageData {
  static final int thumbnailSize = 140;
  int _id;
  String _name;
  String _extension;
  File _imageFile;
  String _imageBase64;
  String _thumbnailUrl;
  Image _image;
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
  }

  ImageData.withThumbnail(String url) {
    this._thumbnailUrl = url;
  }

  ImageData.withImage(Image image, String imageBase64) {
//    _imageFile = file;
    _imageBase64 = imageBase64;
    _image = image;
  }

  dynamic getShopwareObject(String productTitle) {
    assert(productTitle != null);
    assert(productTitle != "");
    if (_thumbnailUrl != null) {
      return {
        "mediaId": _id,
      };
    } else {
//      String extension = path.extension(_imageFile.path).replaceFirst(".", "");
      return {
        "album": -1,
        "file": "data:image/jpeg;base64,$_imageBase64",
//        "link": "data:image/jpeg;base64,$_imageBase64",
        "name": productTitle,
        "description": productTitle
      };
    }
  }

  String get extension => _extension;

  String get name => _name;

  int get id => _id;

  String get thumbnailUrl => _thumbnailUrl;

  Image get image => _image;

  ImageProvider get thumbnail => NetworkImage(
        _thumbnailUrl,
//        fit: BoxFit.cover,
//        height: 150.0,
//        width: 150.0,
      );
}
