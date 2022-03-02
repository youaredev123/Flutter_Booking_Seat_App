import 'package:eventbooking/common/CustomShapeClipper.dart';
import 'package:flutter/material.dart';

Widget safeAreaWidget(BuildContext context, double backBtnOpacity) {
  return SafeArea(
    child: Padding(
      padding: EdgeInsets.only(left: 5, top: 0),
      child: Opacity(
          opacity: backBtnOpacity ?? 1.0,
          child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context, false);
              })),
    ),
  );
}

Widget clipPathWidget({int height}) {
  return ClipPath(
    clipper: CustomShapeClipper(),
    child: Container(
      color: Colors.orange,
      height: height ?? 200,
    ),
  );
}
