import 'dart:math';

import 'package:diKapo/util/Util.dart';
import 'package:flutter/material.dart';

class AvailabilitySelector extends StatefulWidget {
  bool _isAvailable;
  int _quantity;
  Function _inputChanged;

  AvailabilitySelector(bool isAvailable, int quantity, this._inputChanged) {
    this._isAvailable = isAvailable;
    this._quantity = quantity;
  }

  bool get isAvailable => _isAvailable;

  int get quantity => _quantity;

  @override
  _AvailabilitySelectorState createState() => _AvailabilitySelectorState();
}

class _AvailabilitySelectorState extends State<AvailabilitySelector> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          child: Container(
            padding: EdgeInsets.all(Util.relWidth(context, 2.0)),
            width: Util.relWidth(context, 100.0),
            child: Column(
              children: <Widget>[
                Text("Artikel im Shop anzeigen?"),
                Switch(
                    value: widget._isAvailable,
                    onChanged: (value) {
                      setState(() {
                        widget._isAvailable = value;
                        widget._inputChanged();
                      });
                    })
              ],
            ),
          ),
        ),
        Card(
          child: Container(
            padding: EdgeInsets.all(Util.relWidth(context, 2.0)),
            child: Column(
              children: <Widget>[
                Text("Verfügbare Anzahl:"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          widget._quantity = max(widget._quantity - 1, 0);
                          widget._inputChanged();
                        });
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(Util.relWidth(context, 3.0)),
                      child: Text(
                        widget.quantity.toString(),
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          widget._quantity++;
                          widget._inputChanged();
                        });
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
