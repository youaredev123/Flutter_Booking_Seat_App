import 'package:flutter/material.dart';
import 'package:eventbooking/utils/Constant.dart';

class CustomButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed;
  final bool isDisabled;
  final Color textColor;
  final double fontSize;
  final double radius;
  final double opacity;
  final double buttonWidth ;
  final Color backgroundColor ;
  CustomButton({this.text, this.onPressed, this.isDisabled, this.textColor = Colors.white,
      this.fontSize = 20, this.radius, this.opacity = 1.0, this.buttonWidth = 0, this.backgroundColor = customButtonColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: buttonWidth == 0 ? MediaQuery.of(context).size.width: buttonWidth,
      height: 60,
      child: Opacity(
        opacity: opacity,
        child: Card(
            shape: customButtonShape,
            color: backgroundColor,
            elevation: 10,
            child: InkWell(
              onTap: () {
                if(opacity ==1.0) onPressed();
              },
              child: Align(
                alignment: Alignment.center,
                child: Text( text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),),
              ),

            )
        )
        ,
      ),
    );
  }
}
