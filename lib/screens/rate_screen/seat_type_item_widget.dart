import 'package:flutter/material.dart';

class SeatTypeItem extends StatelessWidget {
  SeatTypeItem(this.color, this.type);

  final Color color;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: color, width: 1.0)),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            type,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }
}
