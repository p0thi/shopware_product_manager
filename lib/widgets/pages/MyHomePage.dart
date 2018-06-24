import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/product.dart';
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
  bool _stillLoading = false;

  @override
  initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() {
    setState(() {
      _stillLoading = true;
      _products = new List<Product>();
    });
    SharedPreferences.getInstance().then((prefs) async {
      bool isAuthenticated = await Util.checkCredentials(
          prefs.getString("username"), prefs.getString("pass"));
      print("authenticated: $isAuthenticated");
      http
          .get("${Util.baseApiUrl}articles",
              headers: Util.httpHeaders(
                  prefs.getString("username"), prefs.getString("pass")))
          .then((response) {
        print(response.body);
        Map<String, dynamic> parsedRequest = json.decode(response.body);
        for (var i = 0; i < parsedRequest["data"].length; i++) {
          Product.fromId(parsedRequest["data"][i]["id"]).then((product) {
            setState(() {
              _products.add(product);
              if (_products.length == parsedRequest["data"].length) {
                _stillLoading = false;
              }
            });
          });
        }
      });
    });
  }

  List<Widget> getProductWidgets() {
    List<Widget> result = new List();
    if (_products == null) return result;
    for (Product product in _products) {
      result.add(new ProductPreview(product, onProductDeleted: fetchProducts));
    }
    if (_stillLoading) {
      result.add(ProductPreviewPlaceholder());
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
        heroTag: "homepage",
        onPressed: () {
          fetchProducts();
        },
        tooltip: 'Increment',
        child: new Icon(Icons.refresh),
      ),
    );
  }
}