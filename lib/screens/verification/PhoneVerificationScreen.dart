import 'package:eventbooking/common/index.dart';
import 'package:eventbooking/firebase_services/AuthManager.dart';
import 'package:eventbooking/screens/verification/OTPCodeScreen.dart';
import 'package:eventbooking/utils/Constant.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  String phoneNo = '';
  String smsCode;
  String verificationId;
  CustomProgressDialog ProDiag;

  void goHomeScreen() {}

  Future<void> verifyPhone() async {
    if (phoneNo.length == 0) {
      Global.showToastMessage(
          context: context, msg: 'Pleaes Input Valid Phone Number');
      return;
    }
    ProDiag.show();
    await AuthManager.requestPhoneAuthentication(
        phoneNo: this.phoneNo,
        onSuccess: (verId) {
          ProDiag.hide();
          Global.showToastMessage(
              context: context, msg: 'OTP Code Sent to $phoneNo');
          this.verificationId = verId;
          SessionManager.setPhoneNumber(this.phoneNo);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => OTPCodeScreen(
                        verificationId: verId,
                      )));
        },
        onFailure: (AuthException error) {
          ProDiag.hide();
          Global.showToastMessage(context: context, msg: 'Verification Failed');
        }).catchError((error) {
      ProDiag.hide();
      Global.showToastMessage(context: context, msg: error.toString());
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ProDiag = new CustomProgressDialog(context);

    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              color: Colors.orange,
              height: 200.0,
            ),
          ),
          Center(
            child: Container(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 0.0, bottom: 60.0),
                  child: Text(
                    'Enter your mobile number',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: secondaryColor),
                  ),
                ),
                CustomTextField(
                  iconData: Icons.phone,
                  hintText: 'Enter your phone number',
                  isPhoneKeyboard: true,
                  onChanged: (value) {
                    this.phoneNo = value;
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextView(
                    isCenter: true,
                    text:
                        'Tap Next to verify your account with your mobile number. Then the verification code will be sent to you',
                    textColor: Color(0xFF5F6368),
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
                CustomButton(
                  text: 'Next',
                  onPressed: verifyPhone,
                ),
              ],
            )),
          )
        ],
      ),
    );
  }
}
