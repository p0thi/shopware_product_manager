import 'package:flutter/material.dart';

class PropertyValue {
  String _id;
  final String _value;
  int _postition;
  final String _optionId;
  String _mediaId;
  bool _active;

  PropertyValue(this._value, this._optionId, this._active);

  static List<PropertyValue> getByParentId(
      List<PropertyValue> values, String optionId) {
    List<PropertyValue> result = List();
    for (PropertyValue value in values) {
      if (value._optionId == optionId) {
        result.add(value);
      }
    }
    return result;
  }

  static void setIsActive(
      List<PropertyValue> values, String value, bool isActive) {
    for (PropertyValue myValue in values) {
//      print(myValue.value);
      if (myValue.value == value) {
        myValue.active = isActive;
      }
    }
  }

  static List<PropertyValue> get values => [
        // Größe
        PropertyValue("Kleiner", "1", false),
        PropertyValue("Normal", "1", false),
        PropertyValue("Größer", "1", false),

        // Material
        PropertyValue("Schurwolle", "2", false),
        PropertyValue("Merinowolle", "2", false),

        // Zielgruppe
        PropertyValue("Frau", "4", false),
        PropertyValue("Mann", "4", false),
        PropertyValue("Kind", "4", false),

        // Modell
        PropertyValue("Nordwind", "7", false),

        // Farbe
        ColorPropertyValue("Rot", "6", false, Colors.red),
        ColorPropertyValue("Blau", "6", false, Colors.blue),
        ColorPropertyValue("Grün", "6", false, Colors.green),
        ColorPropertyValue("Braun", "6", false, Colors.brown),
        ColorPropertyValue("Grau", "6", false, Colors.grey),
        ColorPropertyValue("Schwarz", "6", false, Colors.black),
        ColorPropertyValue("Weiß", "6", false, Colors.white),
        ColorPropertyValue("Violett", "6", false, Colors.purple),
        ColorPropertyValue("Orange", "6", false, Colors.orange),
        ColorPropertyValue("Rosa", "6", false, Colors.pink[200]),
        ColorPropertyValue("Gelb", "6", false, Colors.yellow),
      ];

  String get id => _id;

  String get value => _value;

  bool get active => _active;

  set active(bool value) {
    _active = value;
  }

  String get optionId => _optionId;

  String get mediaId => _mediaId;

  int get postition => _postition;
}

class ColorPropertyValue extends PropertyValue {
  final Color _color;

  ColorPropertyValue(value, optionId, selected, this._color)
      : super(value, optionId, selected);

  Color get color => _color;
}
