import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:core';

class StringUtils {

  static String getMainPartFromPhoneNo({@required phonNo: String}) {
    return phonNo.toString().substring(1, phonNo.toString().length);
  }

  static String dropFirst({str: String}) {
    return str.toString().substring(1);
  }

  static String randomString({@required length: int}) {
    const chars = "abcdefghijklmnopqrstuvwxyz";
    Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
    String result = "";
    for (var i = 0; i < length; i++) {
      result += chars[rnd.nextInt(chars.length)];
    }
    return result.toUpperCase();
  }

}