import 'package:eventbooking/common/index.dart';
import 'package:eventbooking/firebase_services/AuthManager.dart';
import 'package:eventbooking/models/User.dart';
import 'package:eventbooking/screens/HomeScreen.dart';
import 'package:eventbooking/utils/Constant.dart';
import 'package:eventbooking/utils/DateUtils.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:flutter/material.dart';

class AddProfileScreen extends StatefulWidget {
  @override
  AddProfileScreenState createState() {
    return AddProfileScreenState();
  }
}

const String DateFormat = 'yyyy-MM-dd';

class AddProfileScreenState extends State<AddProfileScreen> {
  String id;
  Role role;
  String name = '';
  String email = '';
  String phoneNumber = '';
  String code = '';
  String birthday = '';
  Gender gender = Gender.MALE;
  DateTime dom = DateTime.now();
  List<String> ownerClubIds = [];
  List<String> memberClubIds = ["Ko1lK0mM765If885Ey2C"];

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  onSubmit() async {
    if (!checkValidation()) return;
    SessionManager.setUserId(this.id);
    await saveUserInfo();
    SessionManager.hasLoggedIn();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
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

  Future<void> saveUserInfo() async {
    if (this.phoneNumber == "+34777777777") memberClubIds = [];
    User newUser = new User(id, role, name, email, phoneNumber, gender, code,
        birthday, memberClubIds, ownerClubIds);
    try {
      bool _res = await AuthManager.setUserInfo(newUser);
      if (_res) {
        SessionManager.saveUserInfoToLocal(newUser);
      } else {
        Global.showToastMessage(context: context, msg: 'Something went wrong');
      }
    } catch (e) {
      print(e);
    }
  }

  getUserData() async {
    var _id = await AuthManager.getFirebaseUserId();
    var _phoneNumber = SessionManager.getPhoneNumber();
    var _birthday = DateUtils.getTimeStringWithFormat(
        dateTime: DateTime.now(), format: DateFormat);
    setState(() {
      this.id = _id;
      this.phoneNumber = _phoneNumber;
      this.birthday = _birthday;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              color: Colors.orange,
              height: 200,
            ),
          ),
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
              CustomDropDownButton(
                label: 'What is your role?',
                initialValue: roleToString(this.role),
                listItems: ['user', 'admin', 'super_admin'],
                onPressed: (value) {
                  var _role = roleFromString(value);
                  setState(() {
                    this.role = _role;
                  });
                },
              ),
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
                              this.birthday = DateUtils.getTimeStringWithFormat(
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
                initialValue: genderToString(this.gender),
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
        ],
      ),
    );
  }
}
