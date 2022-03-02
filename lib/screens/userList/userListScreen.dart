import 'package:eventbooking/firebase_services/AuthManager.dart';
import 'package:eventbooking/models/User.dart';
import 'package:eventbooking/screens/userList/userDetailModal.dart';
import 'package:eventbooking/styles/mainStyle.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/resources.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> userList = [];

  @override
  void initState() {
    super.initState();
    this.getAllUserList();
  }

  getAllUserList() async {
    Global.showLoading();
    var _userList = await AuthManager.getAllUser();
    Global.dismissLoading();
    setState(() {
      userList = _userList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: Text('User List', style: appBarTitleStyle),
          elevation: 0.2,
          centerTitle: true,
        ),
        body: Container(
            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: userList.length,
                itemBuilder: (context, index) {
                  return userItem(context, userList[index]);
                })));
  }
}

Widget userItem(BuildContext context, User userInfo) {
  return GestureDetector(
    child: Card(
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'username: ${userInfo.name}(${roleToString(userInfo.role)})',
                style: TextStyle(fontSize: 16, height: 1.3),
              ),
              Text(
                'phoneNumber: ${userInfo.phoneNumber}',
                style: TextStyle(fontSize: 16, height: 1.3),
              )
            ],
          )),
      elevation: 2,
      color: lightGreyColor,
    ),
    onTap: () {
      showItemDetailModal(context, userInfo);
    },
  );
}
