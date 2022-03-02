import 'package:eventbooking/common/custom_button.dart';
import 'package:eventbooking/firebase_services/ClubToUserManager.dart';
import 'package:eventbooking/models/index.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';

class InviteModalWidget extends StatefulWidget {
  final BuildContext context;
  final ValueChanged<ClubToUser> onConfirmed;
  final String clubId;

  InviteModalWidget(this.context, this.clubId, this.onConfirmed);

  show() {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: this,
            ));
  }

  @override
  _InviteModalWidgetState createState() => _InviteModalWidgetState();
}

class _InviteModalWidgetState extends State<InviteModalWidget> {
  final textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String phoneNumber = '';
  String userId;
  List<ClubToUser> inviteList;
  Country _selCountry;
  String fullPhoneNumber = '';

  @override
  void initState() {
    _selCountry = Country(
      asset: "assets/flags/es_flag.png",
      dialingCode: "34",
      isoCode: "ES",
      name: "Spain",
    );
    userId = SessionManager.getUserId();
    phoneNumber = SessionManager.getPhoneNumber();

    textController.addListener(() {
      final text = textController.text.toLowerCase();
      textController.value = textController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    super.initState();
  }

  dismiss() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  handleInvite(BuildContext context) async {
    if (textController.text == '') {
      Global.showToastMessage(context: context, msg: 'Input the phoneNumber');
      return;
    }
    if (_selCountry == null) {
      Global.showToastMessage(context: context, msg: 'Select the country code');
    }

    inviteList = [];
    inviteList = await ClubToUserManager.getInviteListForInvite(
        textController.text, widget.clubId);
    inviteList
        .removeWhere((invite) => invite.inviteStatus == InviteStatus.REJECTED);
    //If you user with inputed phone number is already member or is sent the invite notification
    if (inviteList.length > 0) {
      Global.showToastMessage(
          context: context,
          msg:
              'He is already member or is sent the invite notification.There is no need to invite again. Please input another phone number');
      return;
    } else {
      fullPhoneNumber = '+' + _selCountry.dialingCode + textController.text;
      print(fullPhoneNumber);
      ClubToUser newCTU = ClubToUser('', widget.clubId, '', fullPhoneNumber,
          CRole.NONE, MemberStatus.ACTIVE, InviteStatus.SENT, false);
      await ClubToUserManager.create(newCTU);
      widget.onConfirmed(newCTU);
      dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 240,
      margin: EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Enter phone Number',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Row(
              children: <Widget>[
                CountryPicker(
                  showDialingCode: true,
                  showName: false,
                  onChanged: (Country country) {
                    setState(() {
                      _selCountry = country;
                    });
                  },
                  selectedCountry: _selCountry,
                ),
                Expanded(
                  child: TextField(
                      focusNode: _focusNode,
                      onChanged: (value) {},
                      controller: textController,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Nexalight',
                          fontSize: 20,
                          color: Colors.black)),
                ),
              ],
            ),
            CustomButton(
              text: 'Invite',
              buttonWidth: 160,
              onPressed: () {
                handleInvite(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
