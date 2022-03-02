import 'package:eventbooking/common/CustomWidgets.dart';
import 'package:eventbooking/firebase_services/AuthManager.dart';
import 'package:eventbooking/firebase_services/ClubToUserManager.dart';
import 'package:eventbooking/models/User.dart';
import 'package:eventbooking/screens/profile/UpdateProfileScreen.dart';
import 'package:eventbooking/screens/verification/PhoneVerificationScreen.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:flutter/material.dart';

final Color discountBackgroundColor = Color(0xFFFFE080);
final Color flightBorderColor = Color(0xFFEFE6E6);
final Color chipBackgroundColor = Color(0xFFFFFFFF);

final String keyAccountSettings = 'Account Settings';
final String keyLogout = 'Logout';
final String keyClubSettings = 'Clubs';
final String keyInvite = 'Invite';
Role role;

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    role = SessionManager.getRole();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange,
        title: Text(
          "",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            ListViewTopPart(),
            SizedBox(
              height: 5.0,
            ),
            ListBottomPart(),
          ],
        ),
      ),
    );
  }
}

class ListViewTopPart extends StatelessWidget {
  Widget userNameText() {
    var _userName = SessionManager.getUserName();
    return Text(
      _userName,
      style: TextStyle(
          fontSize: 25.0, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget phoneNumberText() {
    var _phoneNumber = SessionManager.getPhoneNumber();
    return Text(
      _phoneNumber,
      style: TextStyle(
          fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        clipPathWidget(),
        Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 5.0,
              ),
              userNameText(),
              SizedBox(
                height: 10.0,
              ),
              phoneNumberText(),
            ],
          ),
        )
      ],
    );
  }
}

TextStyle dropDownMenuStyle = TextStyle(color: Colors.black, fontSize: 12.0);

class ListBottomPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            children: <Widget>[
              Settings(),
            ],
          ),
        ],
      ),
    );
  }
}

class Settings extends StatelessWidget {
  Settings();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Divider(
                color: Colors.grey[300],
                height: 5.0,
              ),
              SettingDetailChip(
                  Icons.settings, "Account Settings", keyAccountSettings),
              Divider(
                color: Colors.grey[300],
                height: 5.0,
              ),
              Visibility(
                visible: role != Role.USER,
                child: SettingDetailChip(Icons.group, "Clubs", keyClubSettings),
              ),
              Divider(
                color: Colors.grey[300],
                height: 5.0,
              ),
              SettingDetailChip(Icons.lock_open, "Logout", keyLogout),
              Divider(
                color: Colors.grey[300],
                height: 5.0,
              ),
              SettingDetailChip(Icons.graphic_eq, "Invite", keyInvite),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingDetailChip extends StatelessWidget {
  final String id;
  final IconData iconData;
  final String lable;

  SettingDetailChip(this.iconData, this.lable, this.id);

  logOut(BuildContext context) {
    SessionManager.hasLoggedOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  clearInvites() async {
    print('now deleting the all notifications');
    String phoneNumber = SessionManager.getPhoneNumber();
    await ClubToUserManager.clearInvites(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return RawChip(
      label: Text(lable),
      labelStyle: TextStyle(
        color: Colors.grey[800],
        fontSize: 15.0,
      ),
      backgroundColor: chipBackgroundColor,
      avatar: Icon(iconData),
      onPressed: () {
        if (id == keyLogout) {
          AuthManager.logOut().then((res) {
            logOut(context);
          }).catchError((error) {
            print(error);
          });
          return;
        } else if (id == keyAccountSettings) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => UpdateProfileScreen()));
        } else if (id == keyClubSettings) {
          Navigator.pushNamed(context, '/club/clubList');
        } else if (id == keyInvite) {
          clearInvites();
          Navigator.pushNamed(context, '/inviteList');
        }
      },
    );
  }
}
