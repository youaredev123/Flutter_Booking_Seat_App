import 'package:eventbooking/utils/Constant.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField(
      {this.iconData,
      this.hintText,
      this.onChanged,
      this.initialValue,
      this.secureText = false,
      this.isKeyboardNumber = false,
      this.isPhoneKeyboard = false});

  final String initialValue;
  final bool secureText;
  final Function(String value) onChanged;
  final IconData iconData;
  final String hintText;
  final bool isKeyboardNumber;
  final bool isPhoneKeyboard;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width - 40,
      child: Card(
        margin: EdgeInsets.only(top: 0.0, bottom: 10.0),
        elevation: 10,
        shape: customButtonShape,
        child: Align(
            alignment: Alignment.center,
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 10),
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  decoration: new BoxDecoration(
                    border: Border(
                      right: new BorderSide(
                        width: 1.0,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                  child: Icon(iconData),
                ),
                Expanded(
                    child: TextFormField(
                  initialValue: initialValue,
                  obscureText: this.secureText,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle: TextStyle(color: Colors.grey)),
                  keyboardType: isKeyboardNumber
                      ? TextInputType.number
                      : isPhoneKeyboard
                          ? TextInputType.phone
                          : TextInputType.text,
                  onChanged: (value) {
                    this.onChanged(value);
                  },
                ))
              ],
            )),
      ),
    );
  }
}
