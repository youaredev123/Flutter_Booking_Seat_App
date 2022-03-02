import 'package:eventbooking/firebase_services/AuthManager.dart';
import 'package:eventbooking/firebase_services/ClubToUserManager.dart';
import 'package:eventbooking/models/User.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/resources.dart';
import 'package:flutter/material.dart';

class MemberListWidget extends StatefulWidget {
  final String clubId;

  MemberListWidget(this.clubId);

  @override
  _MemberListWidgetState createState() => _MemberListWidgetState();
}

class _MemberListWidgetState extends State<MemberListWidget> {
  List<String> _memberList = [];

  @override
  void initState() {
    super.initState();
    getMemberList();
  }

  getMemberList() async {
    Global.showLoading();
    _memberList =
        await ClubToUserManager.getMemberIdListByClubId(widget.clubId);
    setState(() {
      _memberList;
      Global.dismissLoading();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: _memberList.length,
            itemBuilder: (context, index) {
              return MemberItem(context, _memberList[index]);
            }));
  }
}

class MemberItem extends StatefulWidget {
  final BuildContext context;
  final String userId;

  MemberItem(this.context, this.userId);
  @override
  _MemberItemState createState() => _MemberItemState();
}

class _MemberItemState extends State<MemberItem> {
  User memberInfo;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getUserInfo(widget.userId);
  }

  getUserInfo(String userId) async {
    setState(() {
      loading = true;
    });
    memberInfo = await AuthManager.getUserInfoById(userId);
    setState(() {
      memberInfo;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (loading == false && memberInfo != null)
        ? Card(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'username: ${memberInfo.name}',
                      style: TextStyle(fontSize: 16, height: 1.3),
                    ),
                    Text(
                      'phoneNumber: ${memberInfo.phoneNumber}',
                      style: TextStyle(fontSize: 16, height: 1.3),
                    )
                  ],
                )),
            elevation: 2,
            color: lightGreyColor,
          )
        : new Container();
  }
}
