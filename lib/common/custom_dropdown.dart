import 'package:flutter/material.dart';

class CustomDropDownButton extends StatelessWidget {
  final String label;
  final ValueChanged<String> onPressed;
  final List<String> listItems;
  final String initialValue;

  CustomDropDownButton({this.label, this.onPressed, this.listItems,
      this.initialValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(label),
                new DropdownButton<String>(
                  value: initialValue,
                  items:
                  listItems.map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (value){
                    onPressed(value);
                  }
                ),
              ]),
        ],
      ),
    );
  }
}
