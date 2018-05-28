import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/models/Product.dart';
import 'package:flutter_app/util/AppRouter.dart';
import 'package:flutter_app/util/Util.dart';
import 'package:flutter_app/widgets/components/ProductPreview.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Product> _products;

  @override
  initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) async {
      bool isAuthenticated = await Util.checkCredentials(prefs.getString("username"), prefs.getString("pass"));
      print(isAuthenticated);
      http.get("${Util.baseApiUrl}articles", headers: Util.httpHeaders(prefs.getString("username"), prefs.getString("pass")))
          .then((response) async {
            print(response.body);
        Map<String, dynamic> parsedRequest = json.decode(response.body);
        List<Product> tmp = new List();
        for (var i = 0; i < parsedRequest["data"].length; i++) {
          await Product.fromId(parsedRequest["data"][i]["id"]).then((product) => tmp.add(product));
        }
/*
        for (var i = 0; i < 30; i++) {
          tmp.add(Product.fromJson('{"data":{"id":999,"name":"Ich mag Züge","description":"Züge ich mag","mainDetail":{"inStock":${new Random().nextInt(2)},"releaseDate": "2018-03-17T00:00:00+0100"}},"success":true}'));
        }*/
        setState(() {
          _products = tmp;
        });
      });
    });
  }

  List<Widget> getProductWidgets() {
    List<Widget> result = new List();
    if (_products == null)
      return result;
    for(Product product in _products) {
      result.add(new ProductPreview(product));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new ListView(
        children: getProductWidgets(),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => new AppRouter().router().navigateTo(context, "/product/33", transition: TransitionType.native),
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}