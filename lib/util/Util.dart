import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as dartImage;

class Util {
  static Map<String, String> httpHeaders(String username, String pass) {
    return {
      HttpHeaders.AUTHORIZATION:
          "Basic ${base64.encode(utf8.encode("$username:$pass"))}",
    };
  }

  static final String shopUrl = "https://shop.dikapo.eu/";
  static final String baseApiUrl = "${shopUrl}api/";

  static String generateMD5(String data) {
    var content = new Utf8Encoder().convert(data);
    var md5 = crypto.md5;
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  static Future<bool> checkCredentials(String username, String pass) async {
    http.Response res = await http.get("${baseApiUrl}version",
        headers: httpHeaders(username, pass));
    if (res.statusCode == 200) {
      return true;
    }
    return false;
  }

  static double getWidthPercentage(BuildContext context, double percent) {
    double width = 400.0;
    try {
      width = MediaQuery.of(context).size.width;
    } catch (e) {}
    return width * (percent / 100);
  }

  static List<int> cropImage(File file) {
    dartImage.Image image = dartImage.decodeImage(file.readAsBytesSync());
    print("Image Orientation: ${image.exif.orientation}");
    if (image.exif.orientation != null) {}
    // TODO: rotate image
    int width = image.width;
    int height = image.height;
    print("height: $height");
    print("width: $width");
    int minDimension = min(width, height);
    int maxDimension = max(width, height);
    int startingPoint = ((maxDimension - minDimension) / 2).round();
    dartImage.Image thumbnail =
        dartImage.copyCrop(image, startingPoint, 0, minDimension, minDimension);
    print("returning");
    print(thumbnail.exif.orientation);
//    thumbnail.

//    return dartImage.encodePng(thumbnail).;
    return dartImage.encodePng(thumbnail);
  }
}
