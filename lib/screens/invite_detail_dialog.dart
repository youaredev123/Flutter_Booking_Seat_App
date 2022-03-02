import 'package:eventbooking/common/custom_button.dart';
import 'package:flutter/material.dart';

class InviteDetailDialog extends StatefulWidget {
  final BuildContext context;
  final String clubName;
  final VoidCallback onAccepted;
  final VoidCallback onRejected;

  InviteDetailDialog(
      this.context, this.clubName, this.onAccepted, this.onRejected);

  show() {
    showDialog(
        context: context,
        builder: (context) => Container(
              child: this,
            ));
  }

  @override
  _InviteDetailDialogState createState() => _InviteDetailDialogState();
}

class _InviteDetailDialogState extends State<InviteDetailDialog> {
  dismiss() {
    Navigator.pop(context);
  }

 @override
 void dispose() {
   super.dispose();
   dismiss();
 }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          color: Color(0x99FFFFFF),
          child: Center(
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Accept Invite",
                    style:
                        TextStyle(height: 2, fontSize: 24, color: Colors.blue),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                        text: TextSpan(children: <TextSpan>[
                      TextSpan(
                          text: 'You have ben invited to join this club: ',
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                      TextSpan(
                          text: widget.clubName,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black))
                    ])),
                  ),
                  CustomButton(
                    text: 'Accept',
                    backgroundColor: Colors.green,
                    onPressed: () {
                      dismiss();
                      widget.onAccepted();
                    }
                  ),
                  CustomButton(
                    text: 'Reject',
                    backgroundColor: Colors.red,
                    onPressed: () {
                      dismiss();
                      widget.onRejected();
                    },
                  ),
                  CustomButton(
                    text: 'Cancel',
                    backgroundColor: Colors.indigo,
                    onPressed: this.dismiss,
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
