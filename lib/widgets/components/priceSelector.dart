import 'package:flutter/material.dart';
import 'package:flutter_app/util/Util.dart';

class PriceSelector extends StatefulWidget {
  double _price;
  double _fakePrice;
  bool _hasFake;

  double get price => _price;

  PriceSelector(this._price, this._fakePrice, this._hasFake);

  @override
  _PriceSelectorState createState() => _PriceSelectorState();

  double get fakePrice => _fakePrice;

  bool get hasFake => _hasFake;
}

class _PriceSelectorState extends State<PriceSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Card(
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Text(
                    "Vorschau",
                    style: TextStyle(fontSize: Util.relSize(context, 4.0)),
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text("Preis: "),
                      Text(
                        "${widget._price.toStringAsFixed(2)} €",
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: Util.relSize(context, 3.8),
                            fontWeight: FontWeight.bold),
                      ),
                      widget._hasFake
                          ? Text(
                              "${widget._fakePrice.toStringAsFixed(2)} €",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: Util.relSize(context, 3.8),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.lineThrough),
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
                      style: TextStyle(fontSize: Util.relSize(context, 3.5)),
                    ),
                    Switch(
                      value: widget._hasFake,
                      onChanged: (bool value) {
                        setState(() {
                          widget._hasFake = value;
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
                      controller: new TextEditingController(
                          text: widget._price.toString()),
                      keyboardType:
                          TextInputType.numberWithOptions(signed: false),
                      decoration: InputDecoration(labelText: "Preis"),
                      onChanged: (value) {
                        setState(() {
                          widget._price = double.parse(value);
                        });
                      },
                    ),
                  ),
                  Divider(),
                  widget._hasFake
                      ? Container(
                          child: TextField(
                            controller: new TextEditingController(
                                text: widget._fakePrice.toString()),
                            keyboardType:
                                TextInputType.numberWithOptions(signed: false),
                            decoration:
                                InputDecoration(labelText: "Fake Preis"),
                            onChanged: (value) {
                              setState(() {
                                widget._fakePrice = double.parse(value);
                              });
                            },
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
