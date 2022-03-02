import 'package:flutter/material.dart'; 

class BaseScreen extends StatefulWidget {
  final String appBarTitle;
  final bool hasBackButton;
  final Widget body;
  BaseScreen({Key key, this.appBarTitle, this.hasBackButton, this.body});
  
  @override
  _BaseScreenState createState() => _BaseScreenState();
} 

class _BaseScreenState extends State<BaseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Stack(children: <Widget>[
          Visibility(
            visible: widget.hasBackButton,
            child: Align(
              alignment: Alignment.centerLeft,
              child: BackButton(
                
              ),
            )
          )
        ],),
      ),
      body: widget.body,
    );
  }
}