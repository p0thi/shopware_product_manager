import 'package:diKapo/models/imageData.dart';
import 'package:diKapo/models/product.dart';
import 'package:diKapo/util/Util.dart';
import 'package:diKapo/widgets/pages/CreateProductPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductPreview extends StatefulWidget {
  Product _product;
  VoidCallback _onProductsChanged;

  ProductPreview(this._product, {@required VoidCallback onProductsChanged}) {
    this._onProductsChanged = onProductsChanged;
  }

  @override
  _ProductPreviewState createState() => new _ProductPreviewState();
}

class _ProductPreviewState extends State<ProductPreview>
    with TickerProviderStateMixin {
  bool imageAvailable;
  bool isExpanded;
  TextStyle expandedTextStyle;
  EdgeInsetsGeometry tableRowPadding;

  @override
  void initState() {
    super.initState();
    imageAvailable = widget._product.imageDatas.length != 0;
    isExpanded = false;
    expandedTextStyle = TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
    tableRowPadding = EdgeInsets.only(
        top: Util.relHeight(context, 1.0),
        bottom: Util.relHeight(context, 1.0));
    fetchImage();
  }

  Image fetchImage() {
    if (!imageAvailable) return Image.asset("assets/1x1.png");
//    ImageData image = widget._product.imageDatas[0];
    return widget._product.imageDatas[0].thumbnail;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: ListTile(
            title: Center(
              child: new Text(
                widget._product.name,
                style:
                    new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Column(
              children: <Widget>[
                new Text("Noch ${widget._product.quantity} verfügbar."),
                new Text("Veröffentlicht am "
                    "${widget._product.releaseDate.day}."
                    "${widget._product.releaseDate.month}."
                    "${widget._product.releaseDate.year}"),
              ],
            ),
            leading:
//          CircleAvatar(radius: 40.0, backgroundImage: NetworkImage(_imageUrl)),
                Stack(
              children: <Widget>[
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: fetchImage().image, fit: BoxFit.cover),
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
//                  border: Border.all(
//                      width: Util.relWidth(context, 1.0),
//                      color: widget._product.quantity < 1
//                          ? Colors.red
//                          : !widget._product.isActive
//                              ? Colors.orange
//                              : Colors.green)
                  ),
                ),
                Positioned(
                  right: .0,
                  child: Material(
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      child: Container(
                        height: Util.relWidth(context, 5.5),
                        width: Util.relWidth(context, 5.5),
                      ),
                      color: widget._product.quantity < 1
                          ? Colors.red
                          : !widget._product.isActive
                              ? Colors.orange
                              : Colors.green),
                ),
              ],
            ),
            contentPadding: new EdgeInsets.only(
                top: Util.relWidth(context, 3.3),
                right: Util.relWidth(context, 1.3),
                bottom: Util.relWidth(context, 3.3),
                left: Util.relWidth(context, 1.7)),
            trailing: PopupMenuButton<_Choice>(
              onSelected: (choice) {
                _select(context, choice);
              },
              itemBuilder: (context) {
                return _Choice.choices.map((choice) {
                  return PopupMenuItem<_Choice>(
                    value: choice,
                    child: Text(choice.name),
                  );
                }).toList();
              },
            ),
          ),
        ),
        Container(
          alignment: FractionalOffset.topCenter,
          child: AnimatedSize(
            duration: Duration(milliseconds: 300),
            vsync: this,
            alignment: Alignment.topCenter,
            curve: Curves.easeOut,
            child: Container(
                height: isExpanded ? null : .0,
                child: Padding(
                  padding: EdgeInsets.all(Util.relWidth(context, 2.0)),
                  child: Card(
                    elevation: 1.0,
                    child: Container(
                      margin: EdgeInsets.all(Util.relWidth(context, 2.0)),
                      child: Table(
                        columnWidths: {
                          0: FractionColumnWidth(.25),
                          1: FractionColumnWidth(.22),
                          2: FractionColumnWidth(.28),
                          3: FractionColumnWidth(.25),
                        },
                        children: <TableRow>[
                          TableRow(children: <Widget>[
                            Padding(
                              padding: tableRowPadding,
                              child: Text(
                                "Preis:",
                                style: expandedTextStyle,
                              ),
                            ),
                            Padding(
                              padding: tableRowPadding,
                              child: Text(
                                "${widget._product.price} €",
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                            Padding(
                              padding: tableRowPadding,
                              child: Text(
                                "Fake Preis:",
                                style: expandedTextStyle,
                              ),
                            ),
                            Padding(
                              padding: tableRowPadding,
                              child: Text(
                                "${widget._product.fakePrice != null
                                      && widget._product.fakePrice != widget._product.price
                                      ? widget._product.fakePrice
                                      : "----"} €",
                                style: TextStyle(
                                    color: Colors.red,
                                    decoration: TextDecoration.lineThrough),
                              ),
                            )
                          ]),
                          TableRow(children: <Widget>[
                            Padding(
                              padding: tableRowPadding,
                              child: Text(
                                "Bilder:",
                                style: expandedTextStyle,
                              ),
                            ),
                            Padding(
                              padding: tableRowPadding,
                              child:
                                  Text("${widget._product.imageDatas.length}"),
                            ),
                            Padding(
                              padding: tableRowPadding,
                              child: Text(
                                "ArtNr:",
                                style: expandedTextStyle,
                              ),
                            ),
                            Padding(
                              padding: tableRowPadding,
                              child: Text(
                                "${widget._product.artNr}",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ]),
                          TableRow(children: <Widget>[
                            Padding(
                              padding: tableRowPadding,
                              child: Text(
                                "Geändert:",
                                style: expandedTextStyle,
                              ),
                            ),
                            Padding(
                              padding: tableRowPadding,
                              child: Text(
                                  "${widget._product.changedDate.day}.${widget._product.changedDate.month}.${widget._product.changedDate.year}"),
                            ),
                            Padding(
                              padding: tableRowPadding,
                              child: Text(
                                "Aktiv:",
                                style: expandedTextStyle,
                              ),
                            ),
                            Padding(
                              padding: tableRowPadding,
                              child: widget._product.isActive
                                  ? Text(
                                      "Ja",
                                      style: TextStyle(color: Colors.green),
                                    )
                                  : Text(
                                      "Nein",
                                      style: TextStyle(color: Colors.red),
                                    ),
                            ),
                          ])
                        ],
                      ),
                    ),
                  ),
                )),
          ),
        ),
        Divider(
          height: Util.relHeight(context, 1.0),
        )
      ],
    );
  }

  void _select(BuildContext context, _Choice choice) {
    switch (choice.value) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CreateProductPage(widget._product.id, false);
        })).then((value) {
          if (value) widget._onProductsChanged();
        });
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CreateProductPage(widget._product.id, true);
        })).then((value) {
          if (value) widget._onProductsChanged();
        });
        break;
      case 2:
        SharedPreferences.getInstance().then((prefs) {
          showDialog(
              context: context,
//              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                      "Willst den Artikel \"${widget._product.name}\" wirklich löschen? :)"),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text(
                            "Das Löschen kann nicht rückgängig gemacht werden!")
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Ja, löschen!"),
                      onPressed: () async {
                        Product myProduct =
                            await Product.fromId(widget._product.id);
                        http
                            .delete(
                                "${Util.baseApiUrl}articles/${widget._product.id}",
                                headers: Util.httpHeaders(
                                    prefs.get("username"), prefs.get("pass")))
                            .then((response) {
                          for (ImageData imageData in myProduct.imageDatas) {
                            http
                                .delete(
                                    "${Util.baseApiUrl}media/${imageData.id}",
                                    headers: Util.httpHeaders(
                                        prefs.get("username"),
                                        prefs.get("pass")))
                                .then((resp) {});
                          }
                          widget._onProductsChanged();
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text("Nein, nicht löschen"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
        });

        break;
    }
  }
}

class _Choice {
  static List<_Choice> choices = <_Choice>[
    _Choice("Bearbeiten", 0), // edit-product TODO edit product
    _Choice("Duplizieren", 1), // duplicate-product
    _Choice("Löschen", 2),
  ];
  String name;
  int value;

  _Choice(this.name, this.value);
}

class ProductPreviewPlaceholder extends StatelessWidget {
  Widget getTextPlaceholder(double height) {
    return Container(
      margin: EdgeInsets.all(3.0),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        color: Colors.grey[500],
        child: Container(
          height: height,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: .2,
          child: ListTile(
            title: Center(
              child: getTextPlaceholder(17.5),
            ),
            subtitle: Column(
              children: <Widget>[
                getTextPlaceholder(12.5),
                getTextPlaceholder(12.5)
              ],
            ),
            leading: CircleAvatar(
              radius: 40.0,
              backgroundColor: Colors.grey[500],
            ),
            contentPadding: new EdgeInsets.only(
                top: 15.0, right: 8.0, bottom: 15.0, left: 8.0),
            trailing: PopupMenuButton<_Choice>(
//          onSelected: _select,
                itemBuilder: (context) {}),
          ),
        ),
        Positioned.fill(
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: CircularProgressIndicator(),
          )),
        ),
      ],
    );
  }
}
