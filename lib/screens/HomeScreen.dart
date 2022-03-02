import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventbooking/common/notification_badge_widget.dart';
import 'package:eventbooking/firebase_services/InviteManager.dart';
import 'package:eventbooking/models/User.dart';
import 'package:eventbooking/screens/event/EventListScreen.dart';
import 'package:eventbooking/screens/profile/SettingScreen.dart';
import 'package:eventbooking/screens/userList/userListScreen.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'HistoryScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  final List<BottomNavigationBarItem> bottomBarItems = [];
  final bottomBarNavigationStyle = TextStyle(
      fontStyle: FontStyle.normal, color: Colors.black, fontSize: 12.0);
  int currentIndex = 0;
  Widget currentWidget;
  Role role;
  String phoneNumber;
  int notifyCnt = 0;
  Query reference;
  final List<Notification> notifications = [];
  StreamSubscription<QuerySnapshot> _listener;

  HomeScreenState();

  @override
  void initState() {
    super.initState();
    role = SessionManager.getRole();
    phoneNumber = SessionManager.getPhoneNumber();

    this.currentWidget = EventListScreen();
    reference = Firestore.instance
        .collection('ClubToUserList')
        .where('phone_number', isEqualTo: phoneNumber)
        .where('checked', isEqualTo: false)
        .where('invite_status', isEqualTo: 'sent');
    _listener = reference.snapshots().listen((querySnapshot) {
      setState(() {
        notifyCnt = querySnapshot.documents.length;
        print("count===> $notifyCnt");
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _listener?.cancel();
  }

  deleteNotifications() async {
    await InviteManager.deleteNotifcations(this.phoneNumber);
  }

  void onTap(int index) {
    switch (index) {
      case 0:
        setState(() {
          currentWidget = EventListScreen();
          currentIndex = 0;
        });
        break;

      case 1:
        setState(() {
          currentWidget = HistoryScreen();
          currentIndex = 1;
        });
        break;

      case 2:
        setState(() {
          currentWidget = SettingScreen();
          currentIndex = 2;
        });
        break;
      case 3:
        setState(() {
          currentWidget = UserListScreen();
          currentIndex = 3;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: role != Role.SUPERADMIN
              ? <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    title: Text('Home'),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    title: Text('History'),
                  ),
                  BottomNavigationBarItem(
                    icon: InkWell(
                      child: NotificationBadge(this.notifyCnt),
                    ),
                    title: Text('account'),
                  ),
                ]
              : <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    title: Text('Home'),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    title: Text('History'),
                  ),
                  BottomNavigationBarItem(
                    icon: InkWell(
                      child: NotificationBadge(this.notifyCnt),
                    ),
                    title: Text('account'),
                  ),
                  new BottomNavigationBarItem(
                    icon: InkWell(
                      child: new Icon(Icons.local_library),
                    ),
                    title: Text("User List", style: bottomBarNavigationStyle),
                  ),
                ],
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          selectedItemColor: Colors.amber[800],
          onTap: (int index) {
            this.onTap(index);
          },
        ),
        body: currentWidget);
  }
}
