import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/components/photoComposer/imageUnit.dart';

class TrashArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DragTarget(
      onWillAccept: (dynamic value) {
        if (!(value is ImageUnit)) return false;
        return true;
      },
      onAccept: (value) {
        value.deleteImage();
      },
      onLeave: (details) {},
      builder: (BuildContext context, List candidateData, List rejectedData) {
        return Card(
          color: candidateData.isNotEmpty ? Colors.red : Colors.white,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Icon(
              Icons.delete,
              size: 45.0,
            ),
          ),
        );
      },
    );
  }
}
