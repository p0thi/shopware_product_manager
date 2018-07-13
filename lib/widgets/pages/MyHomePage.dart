import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:diKapo/models/product.dart';
import 'package:diKapo/util/Util.dart';
import 'package:diKapo/widgets/components/ProductPreview.dart';
import 'package:diKapo/widgets/pages/CreateProductPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  FilterMethod filterMethod;
  static const List<IconData> fabIcons = const [
    Icons.sort,
    Icons.refresh,
    Icons.add,
  ];
  static const Map<int, String> fabTooltips = const {
    0: "Artikel sortieren",
    1: "Aktualisieren",
    2: "Neuen Artikel anlegen",
  };
  AnimationController animationController;
  List<Product> _products = List();
  bool _stillLoading = false;
  int _productCount = 0;

  @override
  initState() {
    super.initState();
    animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 300));
    fetchProducts();
  }

  void fetchProducts() async {
    setState(() {
      _stillLoading = true;
      _products.clear();
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
        Map<String, dynamic> parsedRequest = json.decode(response.body);
        setState(() {
          _productCount = parsedRequest["data"].length;
        });
        for (var i = 0; i < parsedRequest["data"].length; i++) {
          Product
              .fromId(parsedRequest["data"][i]["id"].toString())
              .then((product) {
            setState(() {
              _products.add(product);
              _products.sort(_sortList);

              _productCount--;
              if (_products.length == parsedRequest["data"].length) {
                _stillLoading = false;
              }
            });
          });
        }
      });
    });
  }

  int _sortList(Product a, Product b) {
    switch (filterMethod) {
      case FilterMethod.release_date:
        return b.releaseDate.compareTo(a.releaseDate);
      case FilterMethod.availability:
        int result = a.quantity.compareTo(b.quantity);
        return result;
      case FilterMethod.name:
        return a.name.compareTo(b.name) * -1;
      case FilterMethod.change_date:
        return b.changedDate.compareTo(a.changedDate);
    }
    return 0;
  }

  List<Widget> getProductWidgets() {
    List<Widget> result = new List();
    if (_products == null) return result;
    for (Product product in _products) {
      result.add(new ProductPreview(product, onProductsChanged: fetchProducts));
    }
    if (_stillLoading) {
      if (_productCount > 0) {
        for (var i = 0; i < _productCount; i++) {
          result.add(ProductPreviewPlaceholder());
        }
      } else {
        result.add(ProductPreviewPlaceholder());
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text(widget.title),
        ),
        body: RefreshIndicator(
          child: new ListView(
            padding: EdgeInsets.all(Util.relWidth(context, 1.0)),
            children: getProductWidgets(),
          ),
          onRefresh: () async {
            Future.delayed(Duration(milliseconds: 1));
            fetchProducts();
          },
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: new List.generate(fabIcons.length, (int index) {
            Widget child = new Container(
              height: 70.0,
              width: 56.0,
              alignment: FractionalOffset.topCenter,
              child: new ScaleTransition(
                scale: new CurvedAnimation(
                  parent: animationController,
                  curve: new Interval(0.0, 1.0 - index / fabIcons.length / 2.0,
                      curve: Curves.easeOut),
                ),
                child: new FloatingActionButton(
                  heroTag: "fab$index",
                  tooltip: fabTooltips[index],
                  backgroundColor: Theme.of(context).cardColor,
                  mini: true,
                  child: new Icon(fabIcons[index],
                      color: Theme.of(context).accentColor),
                  onPressed: () {
                    switch (index) {
                      case 0:
                        showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                title: Center(
                                    child: Text("Liste sortieren nach:")),
                                children: getSortItemList(),
                              );
                            });
                        break;
                      case 1:
                        fetchProducts();
                        break;
                      case 2:
                        Navigator
                            .of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return CreateProductPage.fromProduct(
                              new Product(), true);
                        })).then((value) {
                          if (value) fetchProducts();
                        });
                        break;
                    }
                  },
                ),
              ),
            );
            return child;
          }).toList()
            ..add(
              new FloatingActionButton(
                heroTag: "ExpanderFab",
                tooltip: "Mehr anzeigen",
                child: new AnimatedBuilder(
                  animation: animationController,
                  builder: (BuildContext context, Widget child) {
                    return new Transform(
                      transform: new Matrix4.rotationZ(
                          animationController.value * 0.5 * pi),
                      alignment: FractionalOffset.center,
                      child: new Icon(animationController.isDismissed
                          ? Icons.menu
                          : Icons.close),
                    );
                  },
                ),
                onPressed: () {
                  if (animationController.isDismissed) {
                    animationController.forward();
                  } else {
                    animationController.reverse();
                  }
                },
              ),
            ),
        ));
  }

  List<Widget> getSortItemList() {
    List<Widget> result = List();
    for (FilterMethod method in FilterMethod.values) {
      result.add(Padding(
        padding: EdgeInsets.all(Util.relHeight(context, 2.0)),
        child: Center(
            child: GestureDetector(
          child: Text(
            method.description,
            style: TextStyle(fontSize: 16.0),
          ),
          onTap: () {
            setState(() {
              filterMethod = method;
              _products.sort(_sortList);
            });
            Navigator.of(context).pop();
          },
        )),
      ));
    }
    return result;
  }
}

class FilterMethod {
  static const release_date =
      const FilterMethod._("Datum der Veröffentlichung");
  static const change_date = const FilterMethod._("Datum der letzten Änderung");
  static const name = const FilterMethod._("Name");
  static const availability = const FilterMethod._("Verfügbarkeit");
  static const price = const FilterMethod._("Preis");

  static get values => [release_date, change_date, name, availability, price];

  String get description => _description;
  final String _description;

  const FilterMethod._(this._description);
}
