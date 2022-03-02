import 'package:eventbooking/common/index.dart';
import 'package:eventbooking/firebase_services/AuthManager.dart';
import 'package:eventbooking/screens/HomeScreen.dart';
import 'package:eventbooking/screens/profile/AddProfileScreen.dart';
import 'package:eventbooking/utils/Constant.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

class OTPCodeScreen extends StatefulWidget {
  final String verificationId;

  const OTPCodeScreen({Key key, this.verificationId}) : super(key: key);

  @override
  OTPCodeScrenState createState() {
    return OTPCodeScrenState(this.verificationId);
  }
}

class OTPCodeScrenState extends State<OTPCodeScreen> {
  OTPCodeScrenState(this.verificationId);

  String phoneNumber = '';
  String verificationId;
  String verificationCode;

  double opacity = 1.0;
  CustomProgressDialog ProDiag;

  phoneVerify() async {
    verifyPhoneNumber(
        verificationCode: verificationCode, verificationId: verificationId);
  }

  void verifyPhoneNumber(
      {verificationId: String, verificationCode: String}) async {
    ProDiag.show();
    try {
      var user = await AuthManager.verifyPhoneNumberWithSmsCode(
          verificationId: verificationId, verificationCode: verificationCode);
      if (user != null) {
        print("user===> $user \n");
        var loginStatus = SessionManager.isLogged();
        String localId = SessionManager.getUserId();
        var userInfo = await AuthManager.getUserInfo();
        print(userInfo == null);
        print("=====");
        print("userInfo: $userInfo");
        SessionManager.setPhoneNumber(this.phoneNumber);
        SessionManager.setUserId(user.uid);

        ProDiag.hide();

        if (userInfo != null) {
          if (user.uid == localId && loginStatus == Login_Status.LOGGED_IN) {
            print("my userInfo $userInfo");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          } else {
            SessionManager.saveUserInfoToLocal(userInfo);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          }
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => AddProfileScreen()));
        }
      } else {
        ProDiag.hide();
        print("Please Input Correct Verification Code");
        Global.showToastMessage(
            context: context, msg: 'Please Input Correct Verification Code');
      }
    } catch (e) {
      print(e);
      ProDiag.hide();
      Global.showToastMessage(context: context, msg: 'Something Went Wrong');
    }
  }

  void resend() {
    ProDiag.show();
    AuthManager.requestPhoneAuthentication(
        phoneNo: this.phoneNumber,
        onSuccess: (verId) {
          ProDiag.hide();
          Global.showToastMessage(
              context: context, msg: 'OTP Code Sent to $phoneNumber');
          setState(() {
            this.verificationId = verId;
          });
        },
        onFailure: () {
          ProDiag.hide();
          Global.showToastMessage(context: context, msg: 'Verification Failed');
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    phoneNumber = SessionManager.getPhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    ProDiag = new CustomProgressDialog(context);

    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  ClipPath(
                    clipper: CustomShapeClipper(),
                    child: Container(
                      height: 200,
                      color: Colors.orange,
                    ),
                  ),
                  Center(
                    child: Container(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                          child: Text(
                            'Enter the code that was sent to',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: secondaryColor),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 0.0, bottom: 40.0),
                          child: Text(
                            this.phoneNumber,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: secondaryColor),
                          ),
                        ),
                        PinCodeTextField(
                          autofocus: true,
                          hideCharacter: false,
                          highlight: true,
                          highlightColor: Colors.blue,
                          defaultBorderColor: Colors.black,
                          hasTextBorderColor: Colors.orange,
                          maxLength: 6,
                          onTextChanged: (text) {
                            setState(() {
                              setState(() {
                                verificationCode = text;
                              });
                            });
                          },
                          onDone: (text) {
                            print("DONE $text");
                          },
                          pinCodeTextFieldLayoutType:
                              PinCodeTextFieldLayoutType.AUTO_ADJUST_WIDTH,
                          wrapAlignment: WrapAlignment.start,
                          pinBoxDecoration: ProvidedPinBoxDecoration
                              .underlinedPinBoxDecoration,
                          pinTextStyle: TextStyle(fontSize: 30.0),
                          pinTextAnimatedSwitcherTransition:
                              ProvidedPinBoxTextAnimation.scalingTransition,
                          pinTextAnimatedSwitcherDuration:
                              Duration(milliseconds: 300),
                        ),
                        CustomButton(
                          text: 'Continue',
                          onPressed: phoneVerify,
                        ),
                        CustomButton(
                          text: 'Resend',
                          onPressed: resend,
                          buttonWidth: 200,
                        ),
                      ],
                    )),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
