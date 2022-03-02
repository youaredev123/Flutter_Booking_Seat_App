import 'package:flutter/material.dart';

abstract class NoteDialogListener {
  onNoteSubmitted(String note);
}

class ClaimNoteDialog extends StatelessWidget {
  BuildContext context;

  TextEditingController _controller = TextEditingController();
  ClaimNoteDialog(this.context);

  show() {
    showDialog(
        context: context, builder: (context) => new Container(child: this));
  }

  dismiss() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
        type: MaterialType.transparency,
        child: new Opacity(
          opacity: 1.0,
          child: new Container(
              padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 20.0),
              child: Center(
                child: Container(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('Enter Notes',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black)),
                            Spacer(),
                            SizedBox(width: 50),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  dismiss();
                                },
                                child:
                                    Image.asset('assets/images/icon_close.png'),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Container(
                            height: 2,
                            color: Colors.black,
                          ),
                        ),
                        TextFormField(
                          maxLines: null,
                          controller: _controller,
                          style: TextStyle(color: Color(0xFF8B93A6)),
                          decoration: InputDecoration(border: InputBorder.none),
                        ),
                        Row(
                          children: <Widget>[
                            Text('Send to Provider'),
                            SizedBox(
                              width: 50,
                            ),
                            Text('Send to Payer'),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )),
        ));
  }
}
