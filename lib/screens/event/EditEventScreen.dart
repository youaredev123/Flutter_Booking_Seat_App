import 'package:eventbooking/common/index.dart';
import 'package:eventbooking/firebase_services/EventManager.dart';
import 'package:eventbooking/models/Event.dart';
import 'package:eventbooking/utils/Constant.dart';
import 'package:eventbooking/utils/DateUtils.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditEventScreen extends StatefulWidget {
  @override
  final Event eventInfo;

  EditEventScreen(this.eventInfo);

  EditEventScreenState createState() {
    return EditEventScreenState(eventInfo: this.eventInfo);
  }
}

const String DateFormat = 'yyyy-MM-dd';

class EditEventScreenState extends State<EditEventScreen> {
  EditEventScreenState({this.eventInfo});

  Event eventInfo;

  String ownerName = '';

  String name = '';
  String code = '';
  String createdDate = '';
  String createdTime = '';
  int timestamp = 0;
  DateTime dom;
  TimeOfDay selectedTime;

  onSubmit() async {
    if (!checkVerify()) return;
    Global.showLoading();
    timestamp = DateUtils.getMiliseconds(new DateTime(
        dom.year, dom.month, dom.day, selectedTime.hour, selectedTime.minute));

    eventInfo.name = name;
    eventInfo.code = code;
    eventInfo.createdDate = createdDate;
    eventInfo.createdTime = createdTime;
    eventInfo.timestamp = timestamp;

    var res = await EventManager.updateEvent(eventInfo);
    if (res) {
      print("Successfully update the event.");
      Navigator.pop(context, eventInfo);
    } else {
      Global.showToastMessage(
          context: context, msg: 'Something went wrong. Please try again');
    }
    Global.dismissLoading();
  }

  bool checkVerify() {
    timestamp = DateUtils.getMiliseconds(new DateTime(
        dom.year, dom.month, dom.day, selectedTime.hour, selectedTime.minute));
    if (this.code == '' || this.code.length != 6) {
      Global.showToastMessage(
          context: context,
          msg: 'Pleae Input correct eventCode, it must have six digits');
      return false;
    } else if (this.name == '') {
      Global.showToastMessage(
          context: context, msg: 'Pleae Input your roomCode');
      return false;
    } else if (createdDate == '') {
      Global.showToastMessage(
          context: context, msg: 'Pleae Select create Date');
      return false;
    } else if (createdTime == '') {
      Global.showToastMessage(
          context: context, msg: 'Pleae Select create time');
      return false;
    }

    return true;
  }

  getUserData() {
    var _ownerId = SessionManager.getUserId();
    var _ownerName = SessionManager.getUserName();
    DateTime now = new DateTime.now();

    var _code = eventInfo.code == null ? '' : eventInfo.code;
    var _name = eventInfo.name;
    var _createdDate = eventInfo.createdDate;
    var _dom = DateTime.parse(_createdDate);
    var _createdTime = eventInfo.createdTime;
    var _selectedTime = TimeOfDay(
        hour: int.parse(_createdTime.split(":")[0]),
        minute: int.parse(_createdTime.split(":")[1]));

    print("$_ownerId, $_code, $_ownerName, $_createdDate, $_createdTime");
    setState(() {
      code = _code;
      name = _name;
      ownerName = _ownerName;
      createdDate = _createdDate;
      dom = _dom;
      createdTime = _createdTime;
      selectedTime = _selectedTime;
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

  handleSelectTime(selTime) {
    int hour = selTime.hour;
    int min = selTime.minute;
    print("minute===> $min");
    if (min < 8) {
      min = 0;
    } else if (min < 23) {
      min = 15;
    } else if (min < 38) {
      min = 30;
    } else if (min < 53) {
      min = 45;
    } else {
      if (hour < 23) {
        min = 0;
        hour = hour + 1;
      } else {
        min = 45;
      }
    }
    setState(() {
      this.selectedTime = TimeOfDay(hour: hour, minute: min);
      this.createdTime = '$hour:$min';
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.orange,
          centerTitle: true,
          title: Text("Edit Room",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          )),
      body: Stack(
        children: <Widget>[
          ClipPath(
            child: Container(
              height: 200,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 40.0)),
              Row(children: <Widget>[
                Text(
                  'Select Date',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 140,
                  height: 60,
                  child: Card(
                    elevation: 8,
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
                              this.createdDate =
                                  DateUtils.getTimeStringWithFormat(
                                      dateTime: dateTime, format: DateFormat);
                            });
                          }
                        });
                      },
                      child: Center(
                          child: Text(
                        createdDate,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      )),
                    ),
                  ),
                )
              ]),
              Row(children: <Widget>[
                Text(
                  'Select Date',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 140,
                  height: 60,
                  child: Card(
                    elevation: 8,
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
                              this.createdDate =
                                  DateUtils.getTimeStringWithFormat(
                                      dateTime: dateTime, format: DateFormat);
                            });
                          }
                        });
                      },
                      child: Center(
                          child: Text(
                        createdDate,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      )),
                    ),
                  ),
                )
              ]),
              Row(children: <Widget>[
                Text(
                  'Select Time',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 140,
                  height: 60,
                  child: Card(
                    elevation: 8,
                    shape: customButtonShape,
                    child: InkWell(
                      onTap: () {
                        DateUtils.pickTime(
                                context: context, initialTime: selectedTime)
                            .then((TimeOfDay selectedTime) {
                          if (selectedTime != null) {
                            handleSelectTime(selectedTime);
                          }
                        });
                      },
                      child: Center(
                          child: Text(
                        createdTime,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      )),
                    ),
                  ),
                )
              ]),
              SizedBox(
                height: 20,
              ),
              Divider(
                height: 2.0,
                color: Colors.grey,
              ),
              SizedBox(
                height: 20,
              ),
              CustomTextField(
                iconData: Icons.confirmation_number,
                hintText: 'Enter your eventCode',
                onChanged: (value) {
                  this.code = value;
                },
                initialValue: code,
                isKeyboardNumber: true,
              ),
              CustomTextField(
                  iconData: Icons.event,
                  hintText: 'Enter your eventName',
                  onChanged: (value) {
                    this.name = value;
                  },
                  initialValue: name),
              SizedBox(
                height: 20,
              ),
              Divider(
                height: 2.0,
                color: Colors.grey,
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 20,
                  ),
                  Icon(Icons.person),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    ownerName,
                    style: TextStyle(color: Colors.black, fontSize: 13),
                  ),
                  Spacer(),
                  Text(
                    'No of Slots: 4',
                    style: TextStyle(color: Colors.black, fontSize: 13),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                ],
              ),
              Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: 35),
                    child: Text('Click to Save'),
                  )),
              CustomButton(
                text: 'Save',
                buttonWidth: 200,
                onPressed: () {
                  onSubmit();
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
