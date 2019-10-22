import 'dart:convert';

import 'package:diKapo/models/product.dart';
import 'package:diKapo/models/properties/propertyGroup.dart';
import 'package:diKapo/models/properties/propertyOption.dart';
import 'package:diKapo/models/properties/propertyValue.dart';
import 'package:diKapo/util/Util.dart';
import 'package:diKapo/util/observer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PropertySelector extends StatefulWidget {
  Product _product;
  Function _changed;

  PropertySelector(this._product, this._changed);

  @override
  _PropertySelectorState createState() => _PropertySelectorState();
}

class _PropertySelectorState extends State<PropertySelector>
    with TickerProviderStateMixin
    implements Observer {
  bool fetched = false;
  Map<String, dynamic> fetchedResponse;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      http
          .get("${Util.baseApiUrl}propertyGroups",
              headers:
                  Util.httpHeaders(prefs.get("username"), prefs.get("pass")))
          .then((response) {
        print(response.body);
        fetchedResponse = json.decode(response.body);
        setState(() {
          fetched = true;
        });
      }, onError: (error) => Util.showGeneralError(context));
    });

    if (_getActiveGroup() == null) {
      widget._product.propertyGroups[0].active = true;
    }

    widget._product.addObserver(this);
  }

  void _setGroupActive(int index) {
    _getActiveGroup().active = false;
    setState(() {
      widget._product.propertyGroups[index].active = true;
    });
  }

  List<PropertyValue> _getByParentId(String id) {
    List<PropertyValue> result = List();
    for (PropertyValue value in widget._product.propertyValues) {
      if (value.optionId == id) {
        result.add(value);
      }
    }
    return result;
  }

  PropertyGroup _getActiveGroup() {
    List<PropertyGroup> tmp = List();
    for (PropertyGroup group in widget._product.propertyGroups) {
      if (group.active) {
        tmp.add(group);
      }
    }
    if (tmp.length > 1) throw Exception("Multiple active groups");
    if (tmp.length == 0) return null;
    return tmp[0];
  }

  void _generateOptionSelector(BuildContext context, PropertyOption option) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return _DialogContent(_getByParentId(option.id), () {
            setState(() {});
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return !fetched
        ? CircularProgressIndicator()
        : widget._product.activeGroup == null
            ? Center(
                child: Text(
                  "Im vorherigen Schritt muss mindestens eine Kategorie ausgewählt sein 🙊🙈",
                  style: TextStyle(color: Colors.red, fontSize: 24.0),
                ),
              )
            : Container(
                width: 999.0,
                child: Card(
                  child: Column(
                    children: <Widget>[
                      Table(
                        columnWidths: {
                          0: FractionColumnWidth(.23),
                          2: FractionColumnWidth(.23),
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: <TableRow>[
                          TableRow(children: <Widget>[
                            Container(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: widget._product
                                          .getPossiblePropertyGroups()
                                          .length >
                                      1
                                  ? List.generate(
                                      widget._product
                                          .getPossiblePropertyGroups()
                                          .length, (index) {
                                      return Container(
                                        margin: EdgeInsets.all(
                                            Util.relWidth(context, 1.0)),
                                        decoration: BoxDecoration(
                                            color: widget._product
                                                    .getPossiblePropertyGroups()[
                                                        index]
                                                    .active
                                                ? Colors.grey
                                                : Colors.grey[300],
//                                  border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50.0))),
                                        height: Util.relWidth(context, 3.0),
                                        width: Util.relWidth(context, 3.0),
                                      );
                                    })
                                  : <Widget>[],
                            ),
                            Container(),
                          ]),
                          TableRow(children: <Widget>[
                            widget._product.propertyGroups
                                            .indexOf(_getActiveGroup()) >
                                        0 &&
                                    widget._product
                                            .getPossiblePropertyGroups()
                                            .length >
                                        1
                                ? GestureDetector(
                                    onTap: () {
                                      int currentIndex = widget
                                          ._product.propertyGroups
                                          .indexOf(_getActiveGroup());
                                      setState(() {
                                        _setGroupActive(currentIndex - 1);
                                      });
                                      widget._changed();
                                    },
                                    child: Icon(Icons.arrow_back))
                                : Container(),
                            Container(
                              padding:
                                  EdgeInsets.all(Util.relWidth(context, 2.0)),
                              child: Center(
                                child: Text(
                                  _getActiveGroup().name,
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ),
                            ),
                            widget._product.propertyGroups
                                            .indexOf(_getActiveGroup()) <
                                        widget._product.propertyGroups.length -
                                            1 &&
                                    widget._product
                                            .getPossiblePropertyGroups()
                                            .length >
                                        1
                                ? GestureDetector(
                                    onTap: () {
                                      int currentIndex = widget
                                          ._product.propertyGroups
                                          .indexOf(_getActiveGroup());
                                      setState(() {
                                        _setGroupActive(currentIndex + 1);
                                      });
                                      widget._changed();
                                    },
                                    child: Icon(Icons.arrow_forward))
                                : Container(),
                          ])
                        ],
                      ),
                      Divider(),
                      AnimatedSize(
                        duration: Duration(milliseconds: 200),
                        vsync: this,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: List<Widget>.generate(
                              widget._product.activeGroup.options.length,
                              (i) => Center(
                                  child: ListTile(
                                      leading: Text(widget._product.activeGroup
                                          .options[i].name),
                                      title: Text(
                                        "${widget._product.activeGroup.options[i].activeValues(widget._product.propertyValues).length}   gewählt",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: widget._product.activeGroup
                                                        .options[i]
                                                        .activeValues(widget
                                                            ._product
                                                            .propertyValues)
                                                        .length ==
                                                    0
                                                ? Colors.red
                                                : null),
                                      ),
                                      trailing: Icon(Icons.chevron_right),
                                      onTap: () => _generateOptionSelector(
                                            context,
                                            widget._product.activeGroup
                                                .options[i],
                                          )))),
                        ),
                      )
                    ],
                  ),
                ),
              );
  }

  @override
  void action() {
    setState(() {});
  }
}

class _DialogContent extends StatefulWidget {
  List<PropertyValue> _values;
  Function _onChanged;

  _DialogContent(this._values, this._onChanged);

  @override
  __DialogContentState createState() => __DialogContentState();
}

class __DialogContentState extends State<_DialogContent> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(Util.relWidth(context, 2.0)),
            child: Table(
//              defaultColumnWidth: IntrinsicColumnWidth(),
              columnWidths: {1: IntrinsicColumnWidth()},
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: _createValueView(),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                child: Text(
                  "Fertig!",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.green,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  List<TableRow> _createValueView() {
    List<TableRow> result = List();
    for (PropertyValue value in widget._values) {
//      Widget secondaryWidget;
//      if (value is ColorPropertyValue) {
//        secondaryWidget = Container(
//          child: Center(
//            child: Container(
//              decoration: BoxDecoration(
//                  color: value.color,
//                  border: Border.all(color: Colors.grey),
//                  borderRadius: BorderRadius.all(Radius.circular(50.0))),
//              height: Util.relWidth(context, 5.0),
//              width: Util.relWidth(context, 5.0),
//            ),
//          ),
//        );
//      }
      result.add(TableRow(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value.value),
        ),
//        secondaryWidget ?? Container(),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: Util.relWidth(context, 5.0)),
          child: value.getSecondaryWidget(context),
        ),
        Material(
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
          color: value.active ? Colors.lightGreenAccent : Colors.grey[300],
          child: GestureDetector(
            onTap: () {
              widget._onChanged();
              setState(() {
                value.active = !value.active;
              });
            },
            child: Container(
                padding: EdgeInsets.all(Util.relWidth(context, .7)),
                child: Center(
                    child: Text("${value.active ? "Aktiv" : "Nicht aktiv"}"))),
          ),
        )
      ]));
    }
    return result;
  }
}
