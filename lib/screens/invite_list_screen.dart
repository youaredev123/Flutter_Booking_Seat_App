import 'package:eventbooking/firebase_services/ClubManager.dart';
import 'package:eventbooking/firebase_services/ClubToUserManager.dart';
import 'package:eventbooking/models/index.dart';
import 'package:eventbooking/screens/invite_detail_dialog.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:eventbooking/utils/resources.dart';
import 'package:flutter/material.dart';

class InviteListScreen extends StatefulWidget {
  @override
  _InviteListScreenState createState() => _InviteListScreenState();
}

class _InviteListScreenState extends State<InviteListScreen> {
  List<ClubToUser> _inviteList = [];
  String currentPhoneNumber;
  String userId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userId = SessionManager.getUserId();
    currentPhoneNumber = SessionManager.getPhoneNumber();
    getInviteList();
  }

  getInviteList() async {
    Global.showLoading();
    _inviteList = await ClubToUserManager.getInviteListByPhoneNumber(
        this.currentPhoneNumber);
    _inviteList
        .removeWhere((invite) => invite.inviteStatus == InviteStatus.DONE);
    print("_inviteList: $_inviteList");
    setState(() {
      _inviteList = _inviteList;
    });
    Global.dismissLoading();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          "Invite List",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        elevation: 0.0,
        centerTitle: true,
        leading: InkWell(
          child: Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: ListView.builder(
              padding: EdgeInsets.only(bottom: 24),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: _inviteList.length,
              itemBuilder: (context, index) {
                return InviteItem(context, _inviteList[index]);
              })),
    );
  }
}

class InviteItem extends StatefulWidget {
  final BuildContext context;
  final ClubToUser inviteInfo;

  InviteItem(this.context, this.inviteInfo);
  @override
  _InviteItemState createState() => _InviteItemState();
}

class _InviteItemState extends State<InviteItem> {
  ClubToUser _inviteInfo;
  Club clubInfo;
  bool loading = false;
  String userId;

  @override
  void initState() {
    super.initState();
    userId = SessionManager.getUserId();
    _inviteInfo = widget.inviteInfo;
    getClubInfo(widget.inviteInfo.clubId);
  }

  getClubInfo(String clubId) async {
    setState(() {
      loading = true;
    });
    clubInfo = await ClubManager.getClubInfoById(clubId);
    print("clubInfo: ${clubInfo.toJson().toString()}");
    setState(() {
      clubInfo = clubInfo;
      loading = false;
    });
  }

  onAccepted() async {
    await ClubToUserManager.acceptInvite(_inviteInfo.id, userId);
    setState(() {
      _inviteInfo.inviteStatus = InviteStatus.DONE;
      _inviteInfo.cRole = CRole.USER;
    });
  }

  onRejected() async {
    await ClubToUserManager.rejectInvite(_inviteInfo.id);
    setState(() {
      _inviteInfo.inviteStatus = InviteStatus.REJECTED;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (_inviteInfo.inviteStatus == InviteStatus.SENT) {
          InviteDetailDialog(context, clubInfo.name, onAccepted, onRejected)
              .show();
        }
      },
      child: (loading == false && clubInfo != null)
          ? Card(
              child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  padding: EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'clubName: ${clubInfo.name}',
                        style: TextStyle(fontSize: 16, height: 1.3),
                      ),
                      Spacer(),
                      Text(
                        'inviteStatus: ${inviteStatusToString(_inviteInfo.inviteStatus)}',
                        style: TextStyle(fontSize: 16, height: 1.3),
                      )
                    ],
                  )),
              elevation: 2,
              color: lightGreyColor,
            )
          : new Container(),
    );
  }
}
