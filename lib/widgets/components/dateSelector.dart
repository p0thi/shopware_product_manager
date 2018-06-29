import 'package:diKapo/util/Util.dart';
import 'package:flutter/material.dart';

class DateSelector extends StatefulWidget {
  DateTime _releaseDate;
  Function _inputChanged;

  DateSelector(this._inputChanged, {DateTime initDate}) {
    this._releaseDate = initDate ?? DateTime.now();
  }

  DateTime get releaseDate => _releaseDate;

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          child: Padding(
            padding: EdgeInsets.all(Util.relWidth(context, 2.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(child: Text("Artikel Veröffentlichen am:")),
                Padding(
                  padding: EdgeInsets.all(Util.relWidth(context, 2.0)),
                  child: FlatButton(
                    child: Text("${_intToDay(widget._releaseDate.weekday)}  "
                        "${widget._releaseDate.day}.${widget._releaseDate.month}.${widget._releaseDate.year}"),
                    onPressed: () async {
                      DateTime picked = await showDatePicker(
                          locale: Locale("de", "DE"),
                          context: context,
                          initialDate: widget._releaseDate,
                          firstDate:
                              widget._releaseDate.subtract(Duration(hours: 24)),
                          lastDate:
                              widget._releaseDate.add(Duration(days: 365)));
                      if (picked != null) {
                        setState(() {
                          widget._releaseDate = picked;
                          widget._inputChanged();
                        });
                      }
                    },
                  ),
                ),
                Center(
                  child: Text("(Auf das Datum tippen zum ändern)"),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _intToDay(int value) {
    switch (value) {
      case 1:
        return "Montag";
      case 2:
        return "Dienstag";
      case 3:
        return "Mittwoch";
      case 4:
        return "Donnerstag";
      case 5:
        return "Freitag";
      case 6:
        return "Samstag";
      case 7:
        return "Sonntag";
    }
    return null;
  }
}
