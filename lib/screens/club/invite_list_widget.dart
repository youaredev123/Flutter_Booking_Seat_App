import 'package:eventbooking/common/custom_button.dart';
import 'package:eventbooking/firebase_services/ClubToUserManager.dart';
import 'package:eventbooking/models/index.dart';
import 'package:eventbooking/screens/club/show_invite_modal.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/resources.dart';
import 'package:flutter/material.dart';

class InviteListWidget extends StatefulWidget {
  final String clubId;
  InviteListWidget(this.clubId);

  @override
  _InviteListWidgetState createState() => _InviteListWidgetState();
}

class _InviteListWidgetState extends State<InviteListWidget> {
  List<ClubToUser> _inviteList = [];

  @override
  void initState() {
    super.initState();
    getInviteList();
  }

  getInviteList() async {
    Global.showLoading();
    _inviteList = await ClubToUserManager.getInviteListByClubId(widget.clubId);
    _inviteList
        .removeWhere((invite) => invite.inviteStatus == InviteStatus.DONE);
    setState(() {
      _inviteList = _inviteList;
      Global.dismissLoading();
    });
  }

  addInvite(ClubToUser newCTU) {
    _inviteList.add(newCTU);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _inviteList.length,
                  itemBuilder: (context, index) {
                    return inviteItem(context, _inviteList[index]);
                  })),
        ),
        CustomButton(
          text: 'invite new user',
          onPressed: () async {
            InviteModalWidget(context, widget.clubId, this.addInvite).show();
          },
        )
      ],
    );
  }
}

Widget inviteItem(BuildContext context, ClubToUser inviteInfo) {
  return GestureDetector(
    child: Card(
      elevation: 5.0,
      color: lightGreyColor,
      child: ListTile(
        title: Text(
          'phoneNumber: ${inviteInfo.phoneNumber}',
          style: TextStyle(fontSize: 16, height: 1.3),
        ),
        trailing: Text(
          'status: ${inviteStatusToString(inviteInfo.inviteStatus)}',
          style: TextStyle(fontSize: 16, height: 1.3),
        ),
      ),
    ),
    onTap: () {},
  );
}
