import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/util/Util.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductCategory {
  String _name;
  int _id;

  ProductCategory(this._name, this._id);

  int get id => _id;

  String get name => _name;

  Future<List<ProductCategory>> getCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    http.Response response = await http.get("${Util.baseApiUrl}categories",
        headers: Util.httpHeaders(prefs.get("username"), prefs.get("pass")));

    Map<String, dynamic> parsedRequest = json.decode(response.body);

    List<ProductCategory> result = new List();

    for (var i = 0; i < parsedRequest["data"].length; i++) {
      result.add(ProductCategory(
          parsedRequest["data"][i]["name"], parsedRequest["data"][i]["id"]));
    }
    return result;
  }
}
