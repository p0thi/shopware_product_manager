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

  static double relSize(BuildContext context, double percent) {
    double width = 400.0;
    try {
      width = MediaQuery.of(context).size.width;
    } catch (e) {}
    return width * (percent / 100);
  }

  static List<int> cropImage(String filePath) {
    dartImage.Image image =
        dartImage.decodeImage(File(filePath).readAsBytesSync());
    int width = image.width;
    int height = image.height;
    int minDimension = min(width, height);
    int maxDimension = max(width, height);
    print(maxDimension);
    print(minDimension);
    int startingPoint = ((maxDimension - minDimension) / 2).round();

    dartImage.Image thumbnail =
        dartImage.copyCrop(image, startingPoint, 0, minDimension, minDimension);
    print(thumbnail.width);
    print(thumbnail.height);

    return dartImage.encodeJpg(thumbnail);
//    return Image.memory(dartImage.encodeJpg(thumbnail, quality: 100));
  }
}
