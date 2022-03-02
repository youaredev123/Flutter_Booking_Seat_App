import 'package:flutter/rendering.dart';
import 'package:load/load.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:eventbooking/app.dart';
import 'package:eventbooking/scoped_models/app_model.dart';
import 'package:eventbooking/utils/SessionManager.dart';

void main() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  SessionManager.initialize(sharedPreferences);
  debugPaintSizeEnabled = false;

  runApp(ScopedModel<AppModel>(
    model: AppModel(sharedPreferences),
    child: LoadingProvider(
      themeData: LoadingThemeData(
        tapDismiss: false,
      ),
      child: BookingApp()),
  ));
}