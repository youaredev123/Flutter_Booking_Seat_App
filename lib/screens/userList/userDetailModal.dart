import 'package:eventbooking/firebase_services/AuthManager.dart';
import 'package:eventbooking/models/User.dart';
import 'package:eventbooking/utils/resources.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showItemDetailModal(BuildContext context, User userInfo) {
  final Dialog dialog = Dialog(child: UserDetailDialog(context, userInfo));
  showDialog(context: context, builder: (context) => dialog);
}

class UserDetailDialog extends StatefulWidget {
  final User userInfo;
  final BuildContext context;

  UserDetailDialog(this.context, this.userInfo);
  @override
  _UserDetailDialogState createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends State<UserDetailDialog> {
  int selectedType;
  User _userInfo;

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text('Registered'),
    1: Text('Club Admin'),
  };
  @override
  void initState() {
    super.initState();
    _userInfo = widget.userInfo;
    if (this.widget.userInfo.role == Role.USER) {
      selectedType = 0;
    } else {
      selectedType = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: <Widget>[
          AppBar(
            backgroundColor: Colors.orange,
            title: Text('User Detail'),
            centerTitle: true,
          ),
          UserPropertyItem(_userInfo.name, Icons.person),
          UserPropertyItem(_userInfo.phoneNumber, Icons.phone),
          UserPropertyItem(_userInfo.email, Icons.email),
          Visibility(
            visible: _userInfo.role != Role.SUPERADMIN,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: CupertinoSegmentedControl<int>(
                children: logoWidgets,
                onValueChanged: (int val) async {
                  var _roleStr = 'user';
                  if (val == 1) _roleStr = 'admin';
                  setState(() {
                    this.selectedType = val;
                    if (val == 1) _userInfo.role = Role.ADMIN;
                    _userInfo.role = Role.USER;
                  });
                  await AuthManager.updateUserRole(_userInfo.id, _roleStr);
                },
                groupValue: this.selectedType,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserPropertyItem extends StatelessWidget {
  final String text;
  final IconData icon;
  UserPropertyItem(this.text, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: lightGreyColor,
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(4),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 24),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
