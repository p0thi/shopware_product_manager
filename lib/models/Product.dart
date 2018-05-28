import 'dart:convert';
import 'dart:async';
import 'package:flutter_app/models/ImageData.dart';
import 'package:flutter_app/util/Util.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Product {
  String _id;
  String _name;
  String _description;
  DateTime _releaseDate;
  List<ImageData> _imageDatas;
  int _quantity;

  //JSON String constructor

  static Product fromJson(String jsonString) {
    Product result = new Product();
    Map<String, dynamic> map = json.decode(jsonString);
    result._id = map["data"]["id"].toString();
    result._name = map["data"]["name"].toString();
    result._description = map["data"]["description"].toString();
    result._quantity = map["data"]["mainDetail"]["inStock"];
    result._imageDatas = new List();
    try {
      for(var image in map["data"]["images"]) {
        result._imageDatas.add(new ImageData(
          image["mediaId"].toString(),
          image["path"].toString(),
          image["extension"].toString(),
        ));
      }
    } catch (e) {
    }
    result._releaseDate = DateTime.parse(map["data"]["mainDetail"]["releaseDate"]);
    return result;
  }

  static Future<Product> fromId(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await http.get("${Util.baseApiUrl}articles/$id", headers: Util.httpHeaders(prefs.getString("username"), prefs.getString("pass")))
        .then((response) {
          print(response.body);
      return Product.fromJson(response.body);
    });
    return result;
  }

  int get quantity => _quantity;

  String get description => _description;

  String get name => _name;

  String get id => _id;

  DateTime get releaseDate => _releaseDate;

  List<ImageData> get imageDatas => _imageDatas;

  set quantity(int value) {
    _quantity = value;
  }

  set description(String value) {
    _description = value;
  }

  set name(String value) {
    _name = value;
  }

  set id(String value) {
    _id = value;
  }
}