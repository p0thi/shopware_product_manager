import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  static void showGeneralError() {
    Fluttertoast.showToast(
        msg: "FEHLER! Bitte Pascal bescheid sagen...",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 5,
//        bgcolor: "#e00000",
        textcolor: "#e00000");
  }

  static Future<bool> checkCredentials(String username, String pass) async {
    http.Response res = await http.get("${baseApiUrl}version",
        headers: httpHeaders(username, pass));
    if (res.statusCode == 200) {
      return true;
    }
    Util.showGeneralError();
    return false;
  }

  static double relWidth(BuildContext context, double percent) {
    double width = 400.0;
    try {
      width = MediaQuery.of(context).size.width;
    } catch (e) {}
    return width * (percent / 100);
  }

  static double relHeight(BuildContext context, double percent) {
    double height = 750.0;
    try {
      height = MediaQuery.of(context).size.height;
    } catch (e) {}
    return height * (percent / 100);
  }

  static String cropImage(String filePath) {
    dartImage.Image image =
        dartImage.decodeImage(File(filePath).readAsBytesSync());
    int width = image.width;
    int height = image.height;
    int minDimension = min(width, height);
    int maxDimension = max(width, height);
    int startingPoint = ((maxDimension - minDimension) / 2).round();

    dartImage.Image thumbnail =
        dartImage.copyCrop(image, startingPoint, 0, minDimension, minDimension);

    if (thumbnail.exif != null && thumbnail.exif.orientation != null) {
      if (thumbnail.exif.orientation <= 2) {
        thumbnail = rotate(0, thumbnail);
      } else if (thumbnail.exif.orientation <= 4) {
        thumbnail = rotate(2, thumbnail);
      } else if (thumbnail.exif.orientation <= 6) {
        thumbnail = rotate(1, thumbnail);
      } else if (thumbnail.exif.orientation <= 8) {
        thumbnail = rotate(3, thumbnail);
      }
      thumbnail.exif.rawData = null;
    }

//    return base64Encode(dartImage.encodePng(thumbnail)).toString();
    return base64Encode(dartImage.encodeJpg(thumbnail)).toString();
//    return Image.memory(dartImage.encodeJpg(thumbnail, quality: 100));
  }

  static dartImage.Image rotate(int timesOfRotation, dartImage.Image image) {
    return dartImage.copyRotate(image, timesOfRotation * 90.0);
  }
}
