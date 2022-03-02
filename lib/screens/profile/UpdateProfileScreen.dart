import 'package:eventbooking/common/index.dart';
import 'package:eventbooking/firebase_services/AuthManager.dart';
import 'package:eventbooking/models/User.dart';
import 'package:eventbooking/utils/Constant.dart';
import 'package:eventbooking/utils/DateUtils.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:flutter/material.dart';

class UpdateProfileScreen extends StatefulWidget {
  @override
  UpdateProfileScreenState createState() {
    return UpdateProfileScreenState();
  }
}

const String DateFormat = 'yyyy-MM-dd';

class UpdateProfileScreenState extends State<UpdateProfileScreen> {
  String id;
  Role role;
  String name = '';
  String email = '';
  String phoneNumber = '';
  String code = '';
  String birthday = '';
  Gender gender = Gender.MALE;
  DateTime dom = DateTime.now();
  String roleName = 'user';

  double backButtonOpacity = 1.0;
  Login_Status isLoggedIn = Login_Status.NEW_USER;

  onSubmit() async {
    if (!checkValidation()) return;
    updateUserInfo();
  }

  bool checkValidation() {
    bool emailValid =
        RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    if (this.name == '') {
      Global.showToastMessage(context: context, msg: 'Pleae Input Name');
      return false;
    } else if (this.email == '' || !emailValid) {
      Global.showToastMessage(context: context, msg: 'Pleae Input Valid Email');
      return false;
    } else if (this.code == '') {
      Global.showToastMessage(context: context, msg: 'Pleae Input your code');
      return false;
    } else if (dom == null) {
      Global.showToastMessage(
          context: context, msg: 'Pleae Select Your birthday');
      return false;
    }
    return true;
  }

  void updateUserInfo() async {
    print("phone Number before save $phoneNumber");
    try {
      Map<String, String> payload = {
        "name": this.name,
        "gender": genderToString(this.gender),
        "birthday": this.birthday,
        "email": this.email,
        "code": this.code
      };
      bool res = await AuthManager.updateUserInfo(payload);
      if (res) {
        saveUserInfoToLocal();
        Navigator.of(context).pop();
      } else {
        Global.showToastMessage(
            context: context, msg: 'Something went wrong. Try again');
      }
    } catch (e) {
      print(e);
    }
  }

  void saveUserInfoToLocal() {
    SessionManager.setUserName(this.name);
    SessionManager.setGender(this.gender);
    SessionManager.setBirthday(birthday);
    SessionManager.setEmail(this.email);
    SessionManager.setCode(this.code);
  }

  getUserData() async {
    var _id = SessionManager.getUserId();
    var _userName = SessionManager.getUserName();
    var _gender = SessionManager.getGender();
    var _email = SessionManager.getEmail();
    var _birthday = SessionManager.getBirthday();
    var _code = SessionManager.getCode();
    var _role = SessionManager.getRole();
    String _roleName = roleToString(_role);

    DateTime now = new DateTime.now();
    if (_birthday == '')
      _birthday = DateUtils.getTimeStringWithFormat(
          dateTime: new DateTime.now(), format: DateFormat);

    setState(() {
      this.id = _id;
      this.name = _userName;
      this.gender = _gender;
      this.birthday = _birthday;
      this.email = _email;
      this.code = _code;
      this.role = _role;
      this.roleName = _roleName;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          clipPathWidget(),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 90.0, bottom: 60.0),
                child: Text(
                  'Enter your account details',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                      color: secondaryColor),
                ),
              ),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('What is your role?'),
                              SizedBox(
                                width: 50,
                              ),
                              Text('$roleName'),
                            ])
                      ])),
              CustomTextField(
                  iconData: Icons.person,
                  hintText: 'Enter your name',
                  onChanged: (value) {
                    this.name = value;
                  },
                  initialValue: name),
              CustomTextField(
                  iconData: Icons.email,
                  hintText: 'Enter your email',
                  onChanged: (value) {
                    this.email = value;
                  },
                  initialValue: email),
              CustomTextField(
                iconData: Icons.confirmation_number,
                hintText: 'Enter your code',
                onChanged: (value) {
                  this.code = value;
                },
                initialValue: code,
                isKeyboardNumber: true,
              ),
              Column(children: <Widget>[
                Text(
                  'Select your birthday',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  height: 60,
                  child: Card(
                    elevation: 10,
                    shape: customButtonShape,
                    child: InkWell(
                      onTap: () {
                        DateUtils.pickDOM(
                                context: context,
                                initialDate: dom,
                                firstDate: DateTime(1900, 1, 1))
                            .then((DateTime dateTime) {
                          if (dateTime != null) {
                            setState(() {
                              this.dom = dateTime;
                              birthday = DateUtils.getTimeStringWithFormat(
                                  dateTime: dom, format: DateFormat);
                            });
                          }
                        });
                      },
                      child: Center(
                          child: Text(
                        '$birthday',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      )),
                    ),
                  ),
                )
              ]),
              CustomDropDownButton(
                label: 'What is you gender?',
                initialValue: this.gender == Gender.MALE ? 'male' : 'female',
                listItems: ['male', 'female'],
                onPressed: (value) {
                  var _gender = genderFromString(value);
                  setState(() {
                    this.gender = _gender;
                  });
                },
              ),
              Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text('Tap Save to Continue'),
                  )),
              CustomButton(
                text: 'Save',
                onPressed: onSubmit,
              ),
            ]),
          ),
          safeAreaWidget(context, this.backButtonOpacity),
        ],
      ),
    );
  }
}
