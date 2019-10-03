import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

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
  SortingMethod sortingMethod = SortingMethod.release_date;
  static const List<IconData> fabIcons = const [
    Icons.sort,
    Icons.refresh,
//    Icons.add,
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
        prefs.setInt('artNr', 0);
        for (var i = 0; i < parsedRequest["data"].length; i++) {
          Product.fromId(parsedRequest["data"][i]["id"].toString()).then(
              (product) {
            setState(() {
              _products.add(product);
              _products.sort(_sortList);

              _productCount--;
              if (_products.length == parsedRequest["data"].length) {
                _stillLoading = false;
              }
            });
          }, onError: (error) {
            Util.showGeneralError(context);
          });
        }
      }, onError: (error) {
        print(error);
        Util.showGeneralError(context);
      });
    });
  }

  int _sortList(Product a, Product b) {
    switch (sortingMethod) {
      case SortingMethod.release_date:
        return b.releaseDate.compareTo(a.releaseDate);
      case SortingMethod.availability:
        int result = a.quantity.compareTo(b.quantity);
        return result;
      case SortingMethod.name:
        return a.name.compareTo(b.name) * -1;
      case SortingMethod.change_date:
        return b.changedDate.compareTo(a.changedDate);
      case SortingMethod.price:
        return b.price.compareTo(a.price);
      case SortingMethod.item_number:
        return b.artNr.compareTo(a.artNr);
    }
    return 0;
  }

  List<Widget> getProductWidgets() {
    List<Widget> result = new List();
    if (_products == null) return result;
    result.add(
      Container(height: Util.relHeight(context, 7.0)),
    );
    for (Product product in _products) {
      result.add(new ProductPreview(product, sortingMethod,
          onProductsChanged: fetchProducts));
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
    result.add(
      Container(height: Util.relHeight(context, 15.0)),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: () async {
                  Future.delayed(Duration(milliseconds: 1));
                  fetchProducts();
                },
                child: new ListView(
                  padding: EdgeInsets.all(Util.relWidth(context, 1.0)),
                  children: getProductWidgets(),
                ),
              ),
            ),
            Positioned(
              top: .0,
              left: .0,
              right: .0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.grey.shade300.withOpacity(.5),
                    child: GestureDetector(
                      onTap: () => showSortDialog(),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(Util.relHeight(context, 1.5)),
                          child: Text(
                            "Sortiert nach ${sortingMethod.description}:",
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
                        showSortDialog();
                        break;
                      case 1:
                        fetchProducts();
                        break;
                      case 2:
                        Navigator.of(context)
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

  void showSortDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Center(child: Text("Liste sortieren nach:")),
            children: getSortedItemList(),
          );
        });
  }

  List<Widget> getSortedItemList() {
    List<Widget> result = List();
    for (SortingMethod method in SortingMethod.values) {
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
              sortingMethod = method;
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

class SortingMethod {
  static const release_date =
      const SortingMethod._("Datum der Veröffentlichung");
  static const change_date =
      const SortingMethod._("Datum der letzten Änderung");
  static const name = const SortingMethod._("Name");
  static const availability = const SortingMethod._("Verfügbarkeit");
  static const price = const SortingMethod._("Preis");
  static const item_number = const SortingMethod._("Artikelnummer");

  static get values =>
      [release_date, change_date, name, availability, price, item_number];

  String get description => _description;
  final String _description;

  const SortingMethod._(this._description);
}
