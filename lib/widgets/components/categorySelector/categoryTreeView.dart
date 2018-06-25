import 'package:flutter/material.dart';
import 'package:flutter_app/models/productCategory.dart';
import 'package:flutter_app/util/Util.dart';
import 'package:flutter_app/widgets/components/categorySelector/activatableChip.dart';

class CategoryTreeView extends StatefulWidget {
  List<ProductCategory> _activeCategories;

  CategoryTreeView(this._activeCategories);

  get activeCategories => _activeCategories;

  @override
  _CategoryTreeViewState createState() => _CategoryTreeViewState();
}

class _CategoryTreeViewState extends State<CategoryTreeView> {
  List<ProductCategory> _allCategories;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          child: Padding(
            padding: EdgeInsets.all(Util.relSize(context, 2.0)),
            child: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    "Folgende Kategorien sind momentan ausgewählt:",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                Divider(),
                Container(
                  height: Util.relSize(
                      context,
                      ((1 / 4 * widget._activeCategories.length).toInt() + 1) *
                          5.0),
                  child: GridView.count(
                    childAspectRatio: 5.0,
                    children: List.of(widget._activeCategories.map((category) {
                      return Text(category.name);
                    })),
                    crossAxisCount: 3,
                  ),
                )
              ],
            ),
          ),
        ),
        Card(
          child: Column(
            children: <Widget>[
              Text("Hier die Kategorie/en auswählen:"),
              Divider(),
              Container(
                child: _allCategories != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.of(ProductCategory
                            .getRealRoots(_allCategories)
                            .map((category) => CategoryItem(
                                    category,
                                    _allCategories,
                                    widget._activeCategories, (id, isActive) {
                                  ProductCategory myCategory = ProductCategory
                                      .getById(id, _allCategories);
                                  setState(() {
                                    if (isActive /*&&
                                      !widget._activeCategories.contains(category)*/
                                        ) {
                                      widget._activeCategories.add(myCategory);
                                    }
                                    if (!isActive) {
                                      ProductCategory.removeById(
                                          id, widget._activeCategories);
//                              widget._activeCategories.remove(myCategory);
                                    }
                                    print(widget._activeCategories.length);
                                  });
                                }))),
                      )
                    : Placeholder(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    ProductCategory.getAllCategories().then((list) {
      setState(() {
        _allCategories = list;
      });
    });
  }
}

class CategoryItem extends StatefulWidget {
  bool _isLeaf;
  ProductCategory _category;
  List<ProductCategory> _allCategories;
  List<ProductCategory> _selectedCategories;
  Function(int categoryId, bool isActive) _onChanged;

  CategoryItem(this._category, this._allCategories, this._selectedCategories,
      this._onChanged) {
    _isLeaf = _category.isLeaf;
  }

  @override
  _CategoryItemState createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  bool _highlight = false;
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    Widget inner;
    if (widget._isLeaf) {
      inner = Container(
        padding: EdgeInsets.only(left: Util.relSize(context, 2.0)),
        margin: EdgeInsets.all(Util.relSize(context, 2.0)),
        child: ActivatableChip(
          activated: _highlight,
          label: Text(
            widget._category.name,
            style: TextStyle(fontSize: 18.0),
          ),
          onChanged: (isActive) {
            widget._onChanged(widget._category.id, isActive);
            setState(() {
              _highlight = isActive;
            });
          },
        ),
      );
    } else {
      inner = Container(
        decoration: BoxDecoration(
            border: Border(
                left: BorderSide(width: Util.relSize(context, .3)),
                bottom: _isExpanded
                    ? BorderSide(
                        width: Util.relSize(context, .3), color: Colors.grey)
                    : BorderSide.none)),
        margin: EdgeInsets.all(Util.relSize(context, 3.0)),
        padding: EdgeInsets.only(left: Util.relSize(context, 2.0)),
        width: Util.relSize(context, 900.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(
                  () {
                    _isExpanded = !_isExpanded;
                    print(_isExpanded);
                  },
                );
              },
              child: Row(
                children: <Widget>[
                  Text(
                    widget._category.name,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: Util.relSize(context, 4.0)),
                    child: Icon(_isExpanded
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down),
                  ),
                ],
              ),
            ),
            Container(
              child: Container(
                height: !_isExpanded ? .0 : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.of(
                    widget._category
                        .getChildren(widget._allCategories)
                        .map((myCategory) {
                      return CategoryItem(myCategory, widget._allCategories,
                          widget._selectedCategories, widget._onChanged);
                    }),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.only(left: Util.relSize(context, 1.0)),
      child: inner,
    );
  }

  @override
  void initState() {
    super.initState();
    for (ProductCategory category in widget._selectedCategories) {
      if (widget._category.isParentOf(widget._allCategories, category)) {
        _highlight = true;
        _isExpanded = true;
        break;
      }
      print(category.name);
    }
  }
}
