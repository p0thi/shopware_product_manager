import 'package:diKapo/util/Util.dart';
import 'package:flutter/material.dart';

class PriceSelector extends StatefulWidget {
  double _price;
  double _fakePrice;
  bool _hasFake;
  Function _inputChanged;

  double get price => _price;

  PriceSelector(
      this._price, this._fakePrice, this._hasFake, this._inputChanged);

  @override
  _PriceSelectorState createState() => _PriceSelectorState();

  double get fakePrice => _fakePrice;

  bool get hasFake => _hasFake;
}

class _PriceSelectorState extends State<PriceSelector> {
  TextEditingController _priceController;
  TextEditingController _fakePriceController;
  FocusNode _priceFieldFocusNode = FocusNode();
  FocusNode _fakePriceFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _priceController = TextEditingController(
        text: widget._price.toStringAsFixed(2).replaceAll(".", ","));
    _fakePriceController = TextEditingController(
        text: widget._hasFake
            ? widget._fakePrice.toStringAsFixed(2).replaceAll(".", ",")
            : "deaktiviert");
    return Container(
      child: Column(
        children: <Widget>[
          Card(
            elevation: 3.0,
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Text(
                    "Vorschau:",
                    style: TextStyle(
                        fontSize: Util.relWidth(context, 5.0),
                        color: Colors.blue),
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text("Preis: "),
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context)
                              .requestFocus(_priceFieldFocusNode);
                        },
                        child: Text(
                          "${widget._price.toStringAsFixed(2).replaceAll(".", ",")} €",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: Util.relWidth(context, 3.8),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      widget._hasFake
                          ? GestureDetector(
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(_fakePriceFieldFocusNode);
                              },
                              child: Text(
                                "${widget._fakePrice.toStringAsFixed(2).replaceAll(".", ",")} €",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: Util.relWidth(context, 3.8),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.lineThrough),
                              ),
                            )
                          : Container()
                    ],
                  )
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Soll ein Fake-Preis angezeigt werden?",
                      softWrap: true,
                      style: TextStyle(fontSize: Util.relWidth(context, 3.5)),
                    ),
                    Switch(
                      value: widget._hasFake,
                      onChanged: (bool value) {
                        setState(() {
                          widget._hasFake = value;
                          widget._inputChanged();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Card(
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Container(
                    child: TextField(
                      controller: _priceController,
                      focusNode: _priceFieldFocusNode,
                      keyboardType:
                          TextInputType.numberWithOptions(signed: false),
                      decoration: InputDecoration(labelText: "Preis"),
                      onChanged: (value) {
                        setState(() {
                          widget._price =
                              double.tryParse(value.replaceAll(",", ".")) ?? .0;
                          widget._inputChanged();
                        });
                      },
                    ),
                  ),
                  Divider(),
                  Container(
                    child: TextField(
                      controller: _fakePriceController,
                      focusNode: _fakePriceFieldFocusNode,
                      enabled: widget._hasFake,
                      style: !widget._hasFake
                          ? TextStyle(color: Colors.grey[400])
                          : null,
                      keyboardType:
                          TextInputType.numberWithOptions(signed: false),
                      decoration: InputDecoration(labelText: "Fake Preis"),
                      onChanged: (value) {
                        setState(() {
                          widget._fakePrice =
                              double.tryParse(value.replaceAll(",", ".")) ?? .0;
                          widget._inputChanged();
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
