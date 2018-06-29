import 'dart:async';
import 'dart:convert';

import 'package:diKapo/models/imageData.dart';
import 'package:diKapo/models/productCategory.dart';
import 'package:diKapo/util/Util.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Product {
  String _id = "";
  String _artNr = "";
  String _name = "";
  String _description = "";
  DateTime _releaseDate = DateTime.now();
  DateTime _changedDate = DateTime.now();
  String _tax = "";
  List<ImageData> _imageDatas = List();
  int _quantity = 0;
  List<ProductCategory> _categories = List();
  double _price = .0;
  double _fakePrice = .0;
  bool _isActive = true;

  //JSON String constructor
  Product();

  factory Product.fromJson(String jsonString) {
    Product result = new Product();
    Map<String, dynamic> map = json.decode(jsonString);
    result._id = map["data"]["id"].toString();
    result._name = map["data"]["name"].toString();
    result._description =
        map["data"]["descriptionLong"].toString().replaceAll("<br>", "\n");
    result._quantity = map["data"]["mainDetail"]["inStock"];
    result._artNr = map["data"]["mainDetail"]["number"];
    result._changedDate = DateTime.parse(map["data"]["changed"]).toLocal();
    result._tax = map["data"]["tax"]["name"];
    result._isActive = map["data"]["active"];

    for (var priceUnit in map["data"]["mainDetail"]["prices"]) {
      if (priceUnit["customerGroupKey"] == "EK") {
        result._price =
            (priceUnit["price"] * 119).round() / 100; // 119 = 100 + 19% tax
        result._fakePrice = (priceUnit["pseudoPrice"] * 119).round() / 100;
        break;
      }
    }

    for (var category in map["data"]["categories"]) {
      result._categories.add(ProductCategory(
          category["name"],
          category["id"],
          category["active"],
          category["parentId"],
          category["childrenCount"] != null
              ? int.parse(category["childrenCount"])
              : null,
          category["articleCount"] != null
              ? int.parse(category["articleCount"])
              : null));
    }

    try {
      for (var image in map["data"]["images"]) {
        result._imageDatas.add(new ImageData(
          image["mediaId"],
          image["path"].toString(),
          image["extension"].toString(),
        ));
      }
    } catch (e) {}
    result._releaseDate =
        DateTime.parse(map["data"]["mainDetail"]["releaseDate"]).toLocal();
    return result;
  }

  static Future<Product> fromId(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await http
        .get("${Util.baseApiUrl}articles/$id",
            headers: Util.httpHeaders(
                prefs.getString("username"), prefs.getString("pass")))
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

  String get artNr => _artNr;

  double get fakePrice => _fakePrice;

  double get price => _price;

  List<ProductCategory> get categories => _categories;

  String get tax => _tax;

  DateTime get changedDate => _changedDate;

  bool get isActive => _isActive;
}
