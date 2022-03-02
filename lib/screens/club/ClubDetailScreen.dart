import 'dart:io';
import 'dart:math';

import 'package:eventbooking/common/index.dart';
import 'package:eventbooking/firebase_services/ClubManager.dart';
import 'package:eventbooking/models/Club.dart';
import 'package:eventbooking/screens/club/club_member_list_screeen.dart';
import 'package:eventbooking/styles/mainStyle.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';

class ClubDetailScreen extends StatefulWidget {
  final Club clubInfo;

  ClubDetailScreen({this.clubInfo});

  @override
  _ClubDetailScreenState createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen>
    with ImagePickListener {
  File _image;
  String currentUserId;
  Club _clubInfo;
  String fileExt;
  String name;
  String address1;
  String address2;
  String zipCode;
  String city;
  String country;

  String imageUrl;
  ClubType clubType;
  DateTime dom;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _clubInfo = widget.clubInfo;
    name = widget.clubInfo.name;
    address1 = widget.clubInfo.address1;
    address2 = widget.clubInfo.address2;
    zipCode = widget.clubInfo.zipCode;
    city = widget.clubInfo.city;
    country = widget.clubInfo.country;

    clubType = widget.clubInfo.type;
    currentUserId = SessionManager.getUserId();
    dom = DateTime.parse(widget.clubInfo.createdDate);
  }

  bool checkValidation() {
    if (name == '' ||
        address1 == '' ||
        address2 == '' ||
        zipCode == '' ||
        city == '' ||
        country == '') {
      Global.showToastMessage(
          context: context, msg: 'pls fill in all the fields');
      return false;
    }
    return true;
  }

  handleUpdate(BuildContext context) async {
    Global.showLoading();
    if (checkValidation()) {
      setState(() {
        loading = true;
      });
      imageUrl = await uploadPic();
      _clubInfo.name = name;
      _clubInfo.imageUrl = imageUrl;
      _clubInfo.address1 = address1;
      _clubInfo.address2 = address2;
      _clubInfo.zipCode = zipCode;
      _clubInfo.city = city;
      _clubInfo.country = country;

      bool res = await ClubManager.updateClub(_clubInfo);
      if (res) {
        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        Global.showToastMessage(
            context: context, msg: "Connection error. Please try again");
      }
      Global.dismissLoading();
      Navigator.pop(context, _clubInfo);
    }
    return;
  }

  Future<String> uploadPic() async {
    if (_image == null) return '';
    String fileName = basenameWithoutExtension(_image.path) +
        Random().nextInt(10000).toString() +
        extension(_image.path);

    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    final String url = (await taskSnapshot.ref.getDownloadURL());
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: false,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("update club", style: appBarTitleStyle),
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
                              : _clubInfo.imageUrl == ''
                                  ? Image.asset(
                                      "assets/images/clubMark.png",
                                      fit: BoxFit.fill,
                                    )
                                  : Image.network(
                                      _clubInfo.imageUrl,
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
              CustomButton(
                buttonWidth: 240,
                text: 'Update Club',
                onPressed: () {
                  handleUpdate(context);
                },
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  OutlineButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ClubMemberListScreen(widget.clubInfo.id, 0)));
                    },
                    child: Text("Check members"),
                    borderSide: BorderSide(color: Colors.blue),
                    shape: StadiumBorder(),
                  ),
                  OutlineButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ClubMemberListScreen(widget.clubInfo.id, 1)));
                    },
                    child: Text("Check invites"),
                    borderSide: BorderSide(color: Colors.blue),
                    shape: StadiumBorder(),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
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
