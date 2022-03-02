import 'package:flutter/material.dart';

class TextView extends StatelessWidget {
  final String text;
  double fontSize;
  Color textColor;
  bool isCenter;
  Color shadowColor;
  double shadowOffset;
  bool underline;
  double height;
  TextView(
      {@required this.text,
      this.shadowOffset = 0.0,
      this.underline = false,
      this.shadowColor = Colors.white,
      this.isCenter = false,
      this.fontSize = 16,
      this.textColor = const Color(0xff5A585D),
      this.height = 1});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
            decoration:
                underline ? TextDecoration.underline : TextDecoration.none,
            color: textColor,
            height: height,
            shadows: [
              Shadow(
                  color: shadowColor,
                  offset: Offset(shadowOffset, shadowOffset))
            ],
            fontSize: fontSize),
      ),
      textAlign: isCenter ? TextAlign.center : TextAlign.left,
    );
  }
}
