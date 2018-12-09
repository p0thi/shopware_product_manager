import 'dart:async';
import 'dart:convert';

import 'package:diKapo/models/imageData.dart';
import 'package:diKapo/models/productCategory.dart';
import 'package:diKapo/models/properties/propertyGroup.dart';
import 'package:diKapo/models/properties/propertyOption.dart';
import 'package:diKapo/models/properties/propertyValue.dart';
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

  List<PropertyGroup> _propertyGroups = List();
  List<PropertyValue> _propertyValues = PropertyValue.values;

  Product();

  //JSON String constructor
  factory Product.fromJson(
      String productJsonString, String propertyJsonString) {
    Product result = new Product();
    Map<String, dynamic> productMap = json.decode(productJsonString);
    result._id = productMap["data"]["id"].toString();
    print("Product id: ${result._id}");
    result._name = productMap["data"]["name"].toString();
    result._description = productMap["data"]["descriptionLong"]
        .toString()
        .replaceAll("<br>", "\n")
        .replaceAll("<\/br>", "\n")
        .replaceAll("<p>", "")
        .replaceAll("<\/p>", "");
    result._quantity = productMap["data"]["mainDetail"]["inStock"];
    result._artNr = productMap["data"]["mainDetail"]["number"];
    result._changedDate =
        DateTime.parse(productMap["data"]["changed"]).toLocal();
    result._tax = productMap["data"]["tax"]["name"];
    result._isActive = productMap["data"]["mainDetail"]["active"];

    Map<String, dynamic> propertyMap = json.decode(propertyJsonString);

    for (var group in propertyMap["data"]) {
      PropertyGroup myGroup = new PropertyGroup(
          group["id"].toString(),
          group["position"],
          group["name"],
          group["comparable"],
          group["sortMode"]);
      if (myGroup.id == productMap["data"]["filterGroupId"].toString()) {
        myGroup.active = true;
      }
      result._propertyGroups.add(myGroup);
      for (var option in group["options"]) {
        myGroup.options.add(new PropertyOption(
            option["id"].toString(), option["name"], option["filterable"]));
      }
    }
    for (var propertyValue in productMap["data"]["propertyValues"]) {
      PropertyValue.setIsActive(
          result._propertyValues, propertyValue["value"].toString(), true);
    }
    for (var priceUnit in productMap["data"]["mainDetail"]["prices"]) {
      if (priceUnit["customerGroupKey"] == "EK") {
        result._price = (priceUnit["price"] *
                    (100 + int.parse(result._tax.replaceAll("%", ""))))
                .round() /
            100;
        result._fakePrice = (priceUnit["pseudoPrice"] *
                    (100 + int.parse(result._tax.replaceAll("%", ""))))
                .round() /
            100;
        break;
      }
    }

    for (var category in productMap["data"]["categories"]) {
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
    result._categories.sort((a, b) {
      if (a.isLeaf) return -1;
      return a.name.compareTo(b.name);
    });

    try {
      for (var image in productMap["data"]["images"]) {
        result._imageDatas.add(new ImageData(
          image["mediaId"],
          image["path"].toString(),
          image["extension"].toString(),
        ));
      }
    } catch (e) {}
    result._releaseDate =
        DateTime.parse(productMap["data"]["mainDetail"]["releaseDate"])
            .toLocal();
    return result;
  }

  static Future<Product> fromId(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var productResult = await http.get("${Util.baseApiUrl}articles/$id",
        headers: Util.httpHeaders(
            prefs.getString("username"), prefs.getString("pass")));
    var propertyResult = await http.get("${Util.baseApiUrl}propertyGroups",
        headers: Util.httpHeaders(prefs.get("username"), prefs.get("pass")));
//    print(productResult.body);
//    print(propertyResult.body);
    Product result = Product.fromJson(productResult.body, propertyResult.body);
    print(result.name);
    return result;
  }

  Map<String, dynamic> getShopwareGroup() {
    return {"id": activeGroup.id};
  }

  List<Map<String, dynamic>> getShopwareValues() {
    List<Map<String, dynamic>> result = List();
    for (PropertyOption option in activeGroup.options) {
      for (PropertyValue value in option.activeValues(propertyValues)) {
        result.add({
//          "id": value.id,
          "value": value.value,
//          "optionId": option.id,
          "option": {
            "id": option.id,
          },
//          "position": value.postition,
        });
      }
    }
    return result;
  }

  PropertyGroup get activeGroup {
    for (PropertyGroup group in propertyGroups) {
      if (group.active) {
        return group;
      }
    }
    return null;
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

  List<PropertyValue> get propertyValues => _propertyValues;

  List<PropertyGroup> get propertyGroups => _propertyGroups;
}
