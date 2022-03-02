import 'dart:io';
import 'dart:math';

import 'package:eventbooking/common/index.dart';
import 'package:eventbooking/firebase_services/ClubManager.dart';
import 'package:eventbooking/firebase_services/ClubToUserManager.dart';
import 'package:eventbooking/models/index.dart';
import 'package:eventbooking/styles/mainStyle.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';

class CreateClubScreen extends StatefulWidget {
  @override
  _CreateClubScreenState createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends State<CreateClubScreen>
    with ImagePickListener {
  File _image;
  String currentUserId;
  String currentUserName;
  String currentUserPhoneNumber;

  String fileExt;
  String name;

  String address1;
  String address2;
  String zipCode;
  String city;
  String country;

  String imageUrl = '';
  ClubType clubType;
  DateTime dom;
  List<Member> memberList = [];
  List<Invite> inviteList = [];
  bool loading = false;
  var future;

  @override
  void initState() {
    super.initState();
    name = '';
    address1 = '';
    address2 = '';
    zipCode = '';
    city = '';
    country = '';
    clubType = ClubType.PRIVATE;
    currentUserId = SessionManager.getUserId();
    currentUserName = SessionManager.getUserName();
    currentUserPhoneNumber = SessionManager.getPhoneNumber();
    dom = DateTime.now();
  }

  bool checkValidation() {
    if (name == '' ||
        address1 == '' ||
        address2 == '' ||
        zipCode == '' ||
        city == '' ||
        country == '') {
      Global.showToastMessage(
          context: context, msg: 'pls fill out all the fields');
      return false;
    }
    return true;
  }

  handleCreate(BuildContext context) async {
    if (checkValidation()) {
      setState(() {
        loading = true;
        Global.showLoading();
      });
      imageUrl = await uploadPic();
      String _createdDate = dom.toString();

      Club _newClub = Club('', name, address1, address2, zipCode, city, country,
          clubType, imageUrl, _createdDate, memberList, inviteList);

      var newClub = await ClubManager.createClub(_newClub);
      ClubToUser newCTU = ClubToUser(
          '',
          newClub.id,
          currentUserId,
          currentUserPhoneNumber,
          CRole.ADMIN,
          MemberStatus.ACTIVE,
          InviteStatus.DONE,
          true);
      await ClubToUserManager.create(newCTU);
      setState(() {
        Global.dismissLoading();
        loading = false;
        name = '';
        address1 = '';
        address2 = '';
        zipCode = '';
        city = '';
        country = '';
        clubType = ClubType.PRIVATE;
        memberList = [];
        inviteList = [];
      });
      Navigator.pop(context, newClub);
    }
    return;
  }

  Future<String> uploadPic() async {
    if (_image == null) return '';
    String fileName = basenameWithoutExtension(_image.path) +
        Random().nextInt(10000).toString() +
        extension(_image.path);
    print(fileName);

    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    final String url = (await taskSnapshot.ref.getDownloadURL());
    print('taskSnapshot: ${taskSnapshot.storageMetadata.path}');
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: loading,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Create club", style: appBarTitleStyle),
            backgroundColor: Colors.orange,
          ),
          body: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Color(0xff476cfb),
                      child: ClipOval(
                        child: new SizedBox(
                          width: 200.0,
                          height: 160.0,
                          child: (_image != null)
                              ? Image.file(
                                  _image,
                                  fit: BoxFit.fill,
                                )
                              : Image.asset(
                                  "assets/images/clubMark.png",
                                  fit: BoxFit.fill,
                                ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 60.0),
                    child: IconButton(
                      icon: Icon(
                        FontAwesomeIcons.camera,
                        size: 30.0,
                      ),
                      onPressed: () {
                        ImagePickerDialog(context, this).show();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              CustomTextField(
                iconData: Icons.person,
                hintText: 'Enter your name',
                onChanged: (value) {
                  this.name = value;
                },
                initialValue: name,
              ),
              Row(children: <Widget>[
                Expanded(child: Divider()),
                Text("  Address  "),
                Expanded(child: Divider()),
              ]),
              SizedBox(
                height: 12,
              ),
              CustomTextField(
                iconData: FontAwesomeIcons.addressBook,
                hintText: 'Enter your addresss1',
                onChanged: (value) {
                  this.address1 = value;
                },
                initialValue: address1,
              ),
              CustomTextField(
                iconData: FontAwesomeIcons.addressBook,
                hintText: 'Enter your addresss2',
                onChanged: (value) {
                  this.address2 = value;
                },
                initialValue: address2,
              ),
              CustomTextField(
                iconData: FontAwesomeIcons.pen,
                hintText: 'Enter your zipCode',
                onChanged: (value) {
                  this.zipCode = value;
                },
                isKeyboardNumber: true,
                initialValue: zipCode,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomTextField(
                        iconData: FontAwesomeIcons.city,
                        hintText: 'city',
                        onChanged: (value) {
                          this.city = value;
                        },
                        initialValue: city,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: CustomTextField(
                        iconData: Icons.landscape,
                        hintText: 'country',
                        onChanged: (value) {
                          this.country = value;
                        },
                        initialValue: country,
                      ),
                    ),
                  ],
                ),
              ),
              Row(children: <Widget>[
                Expanded(child: Divider()),
                Text(
                  "  ~  ",
                  style: TextStyle(fontSize: 20),
                ),
                Expanded(child: Divider()),
              ]),
              CustomDropDownButton(
                label: 'What is club type?',
                initialValue: clubTypeToString(this.clubType),
                listItems: ['private', 'public'],
                onPressed: (value) {
                  var _ct = clubTypeFromString(value);
                  setState(() {
                    this.clubType = _ct;
                  });
                },
              ),
              CustomButton(
                buttonWidth: 240,
                text: 'Create Club',
                onPressed: () {
                  handleCreate(context);
                },
              )
            ],
          ))),
    );
  }

  @override
  onImagePicked(File image, String ext) {
    setState(() {
      _image = image;
      fileExt = ext;
    });
    print(_image.path);
    print(fileExt);
    return null;
  }
}
