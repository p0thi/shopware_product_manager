import 'package:flutter/material.dart';

class ActivatableChip extends StatefulWidget {
  Widget _label;
  bool _activated;
  Color _activeColor;
  ValueChanged<bool> _onChanged;

  ActivatableChip(
      {@required Widget label,
      bool activated,
      Color activeColor,
      @required ValueChanged onChanged}) {
    this._onChanged = onChanged;
    this._label = label ?? null;
    this._activated = activated ?? false;
    this._activeColor = activeColor ?? Colors.lightGreen;
  }

  bool get activated => _activated;

  @override
  _ActivatableChipState createState() => _ActivatableChipState();
}

class _ActivatableChipState extends State<ActivatableChip> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        child: Chip(
          label: widget._label,
          backgroundColor: (widget._activeColor != null && widget._activated)
              ? widget._activeColor
              : Colors.black12,
        ),
        onTap: () {
          setState(() {
            widget._activated = !widget._activated;
            widget._onChanged(widget._activated);
          });
        },
      ),
    );
  }
}
