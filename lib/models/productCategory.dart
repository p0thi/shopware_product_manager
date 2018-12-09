import 'dart:async';
import 'dart:convert';

import 'package:diKapo/util/Util.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductCategory {
  String _name;
  int _id;
  bool _active;
  int _parentId;
  int _childrenCount;
  int _articleCount;

  static List<String> acceptableNames = <String>[
    'Mützen',
    'Stirnbänder',
    'Accessoires'
  ];

  ProductCategory(this._name, this._id, this._active, this._parentId,
      this._childrenCount, this._articleCount);

  ProductCategory getParent(List<ProductCategory> list) {
    if (_parentId == null) return null;
    if (!list.contains(this)) return null;

    ProductCategory result;
    for (ProductCategory category in list) {
      if (category.id == _parentId) {
        result = category;
        break;
      }
    }
    return result;
  }

  List<ProductCategory> getChildren(List<ProductCategory> list) {
    List<ProductCategory> result = List();
    if (_childrenCount == 0) return result;
    for (ProductCategory category in list) {
      if (category.parentId == _id) {
        result.add(category);
      }
    }
    return result;
  }

  bool isParentOf(List<ProductCategory> list, ProductCategory category) {
    if (category == null) return false;
    if (_id == category.id) return true;
    if (isLeaf) return false;
    bool result = false;
    for (ProductCategory myCategory in getChildren(list)) {
      result = result || myCategory.isParentOf(list, category);
    }
    return result;
  }

  bool get isLeaf {
    return _childrenCount == 0;
  }

  static void removeById(int id, List<ProductCategory> list) {
    list.remove(getById(id, list));
  }

  static ProductCategory getById(int id, List<ProductCategory> list) {
    for (ProductCategory category in list) {
      if (category.id == id) return category;
    }
    return null;
  }

  static List<ProductCategory> getRealRoots(List<ProductCategory> list) {
    List<ProductCategory> result = List();
    for (ProductCategory category in list) {
      if (category.parentId == 3) {
        result.add(category);
      }
    }
    return result;
  }

  static Future<List<ProductCategory>> getAllCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    http.Response response = await http.get("${Util.baseApiUrl}categories",
        headers: Util.httpHeaders(prefs.get("username"), prefs.get("pass")));

    Map<String, dynamic> parsedRequest = json.decode(response.body);

    List<ProductCategory> result = new List();

    for (var i = 0; i < parsedRequest["data"].length; i++) {
      result.add(ProductCategory(
          parsedRequest["data"][i]["name"],
          parsedRequest["data"][i]["id"],
          parsedRequest["data"][i]["active"],
          parsedRequest["data"][i]["parentId"],
          int.parse(parsedRequest["data"][i]["childrenCount"]),
          int.parse(parsedRequest["data"][i]["articleCount"])));
    }
    return result;
  }

  int get id => _id;

  String get name => _name;

  bool get active => _active;

  int get parentId => _parentId;

  int get childrenCount => _childrenCount;

  int get articleCount => _articleCount;
}
