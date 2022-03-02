import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:load/load.dart';

class Global {
  static bool TEST_MODE = true;
  static var future;
  static int eventMemberCnt = 4;

  static showLoading() async {
    future = await showLoadingDialog();
  }

  static dismissLoading() async {
    future.dismiss();
  }

  static void showToastMessage(
      {@required context: BuildContext, @required msg: String}) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Color.fromRGBO(30, 30, 30, 0.6),
        textColor: Colors.white);
  }
}
