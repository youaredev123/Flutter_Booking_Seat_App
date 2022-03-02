import 'dart:async';
import 'package:flutter/material.dart';
import 'package:eventbooking/screens/verification/PhoneVerificationScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

List<Color> colors = [
  Colors.red,
  Colors.green,
  Colors.indigo,
  Colors.pinkAccent,
  Colors.blue,
];

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    startTime();
  }

  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigationPage);
  }

  navigationPage() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 50.0,
                        child: Icon(
                          Icons.room_service,
                          color: Colors.orange[500],
                          size: 50.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4.0),
                      ),
                      const Text.rich(
                        TextSpan(
                          // default text style
                          children: <TextSpan>[
                            TextSpan(
                                text: ' Boooking ',
                                style: TextStyle(
                                    fontSize: 35.0,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                    fontFamily: 'Ubuntu')),
                            TextSpan(
                                text: 'Seat ',
                                style: TextStyle(
                                    fontSize: 35.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                    fontFamily: 'Ubuntu')),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 8.0),
                    ),
                    const Text.rich(
                      TextSpan(
                        // default text style
                        children: <TextSpan>[
                          TextSpan(
                              text: ' Made by ',
                              style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                  fontFamily: 'Ubuntu')),
                          TextSpan(
                              text: 'Ruben from Spain',
                              style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                  fontFamily: 'Ubuntu')),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
