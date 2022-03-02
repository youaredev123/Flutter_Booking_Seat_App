import 'package:eventbooking/screens/club/ClubDetailScreen.dart';
import 'package:eventbooking/screens/club/ClubListScreen.dart';
import 'package:eventbooking/screens/club/CreateClubScreen.dart';
import 'package:eventbooking/screens/invite_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:eventbooking/scoped_models/app_model.dart';
import 'package:eventbooking/screens/SplashScreen.dart';

class BookingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(
      builder: (context, child, model) => MaterialApp(
        title: 'Booking seat',
        theme: model.appTheme,
        home: SplashScreen(),
        routes: {
          '/club/clubList': (context) => ClubListScreen(),
          '/club/clubDetail': (context) => ClubDetailScreen(),
          '/club/createClub': (context) => CreateClubScreen(),
          '/inviteList': (context) => InviteListScreen(),
        }
//        home: MyApp(),
      )
    );
  }
}
