import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int counter;
  NotificationBadge(this.counter);

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new Icon(Icons.supervisor_account),
        Visibility(
          visible: counter != 0,
          child: new Positioned(
            right: 0,
            top: 0,
            child: new Container(
              padding: EdgeInsets.all(2),
              decoration: new BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: BoxConstraints(
                minWidth: 14,
                minHeight: 14,
              ),
              child: Text(
                '$counter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        )
      ],
    );
  }
}

