import 'package:diKapo/models/properties/propertyOption.dart';

class PropertyGroup {
  final String _id;
  final int _position;
  String _name;
  List<PropertyOption> _options = List();
  bool _comparable;
  int _sortMode;
  bool _active;

  PropertyGroup(
      this._id, this._position, this._name, this._comparable, this._sortMode,
      {bool active: false}) {
    this._active = active ?? false;
  }

  static PropertyGroup getById(List<PropertyGroup> groups, String id) {
    for (PropertyGroup group in groups) {
      if (group._id == id) {
        return group;
      }
    }
    return null;
  }

//  static void setValueActive(
//      PropertyGroup group, String name, String optionId, bool isActive) {
//    PropertyOption currentOption = PropertyOption.fromId(optionId);
//    for (PropertyValue value in currentOption.values) {
//      if (value.value == name) {
//        value.active = isActive;
//      }
//    }
//    if (!group._options.contains(currentOption)) {
//      group._options.add(currentOption);
//    }
//  }

  static List<PropertyGroup> get groups => [
        PropertyGroup("1", 0, "Mützen", true, 0),
        PropertyGroup("5", 0, "Stirnband", true, 0),
      ];

  String get name => _name;

  bool get active => _active;

  set active(bool value) {
    _active = value;
  }

  List<PropertyOption> get options => _options;

  int get sortMode => _sortMode;

  bool get comparable => _comparable;

  int get position => _position;

  String get id => _id;
}
