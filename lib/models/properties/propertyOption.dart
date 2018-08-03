import 'package:diKapo/models/properties/propertyValue.dart';

class PropertyOption {
  final String _id;
  String _name;
  bool _filterable;

  PropertyOption(this._id, this._name, this._filterable);

//  static List<PropertyValue> getActiveValues(PropertyOption option) {
//    List<PropertyValue> result = List();
//    for (PropertyValue value in PropertyValue.getByParentId(option._id)) {
//      if (value.active) {
//        result.add(value);
//      }
//    }
//    return result;
//  }

  List<PropertyValue> activeValues(List<PropertyValue> values) {
    List<PropertyValue> result = List();
    for (PropertyValue value in children(values)) {
      if (value.active) {
        result.add(value);
      }
    }
    return result;
  }

  List<PropertyValue> children(List<PropertyValue> values) {
    List<PropertyValue> result = List();
    for (PropertyValue value in values) {
      if (value.optionId == id) {
        result.add(value);
      }
    }
    return result;
  }

  static List<PropertyOption> get options => [
        PropertyOption("1", "Größe", true),
        PropertyOption("2", "Material", true),
        PropertyOption("4", "Zielgruppe", true),
        PropertyOption("6", "Farbe", true),
      ];

  String get id => _id;

  String get name => _name;
}
