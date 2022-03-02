import 'package:eventbooking/common/index.dart';
import 'package:eventbooking/firebase_services/EventManager.dart';
import 'package:eventbooking/models/index.dart';
import 'package:eventbooking/utils/Constant.dart';
import 'package:eventbooking/utils/DateUtils.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class EventAddListener {
  void onEventAdded();
}

class AddEventScreen extends StatefulWidget {
  @override
  final EventAddListener customListener;
  final List<Map<String, dynamic>> myClubInfoList;
  AddEventScreen({this.customListener, this.myClubInfoList = const []});

  AddEventScreenState createState() {
    return AddEventScreenState();
  }
}

const String DateFormat = 'yyyy-MM-dd';

class AddEventScreenState extends State<AddEventScreen> {
  AddEventScreenState();
  EventManager eManager = new EventManager();
  String id;
  String eventCode;
  String eventName;
  String clubId;
  String ownerId = '';
  String ownerName = '';
  String createdDate = '';
  String createdTime = '';
  EventStatus eventStatus;
  List<Slot> slotList = [];
  int timestamp = 0;
  String clubName = '';

  DateTime dom = new DateTime.now();
  TimeOfDay selectedTime;

  onSubmit() async {
    if (!checkValidate()) return;
    await createEvent();
  }

  bool checkValidate() {
    timestamp = DateUtils.getMiliseconds(new DateTime(
        dom.year, dom.month, dom.day, selectedTime.hour, selectedTime.minute));
    if (this.eventCode == '' || this.eventCode?.length != 6) {
      Global.showToastMessage(
          context: context,
          msg: 'Pleae Input correct roomCode, it must have six digits');
      return false;
    } else if (this.eventName == '') {
      Global.showToastMessage(
          context: context, msg: 'Pleae Input your roomCode');
      return false;
    } else if (createdDate == '') {
      Global.showToastMessage(
          context: context, msg: 'Pleae Select booking Date');
      return false;
    } else if (createdTime == '') {
      Global.showToastMessage(
          context: context, msg: 'Pleae Select booking time');
      return false;
    } else if (timestamp < DateUtils.getMiliseconds(DateTime.now())) {
      Global.showToastMessage(
          context: context,
          msg:
              'Please Select Valid time and date. Please select a time after now.');
      return false;
    } else {
      return true;
    }
  }

  createEvent() async {
    Global.showLoading();

    List<Slot> slotList = [];
    slotList.add(Slot(0, SlotStatus.Booked, ownerId, ownerName, 0));
    slotList.add(Slot(1, SlotStatus.Available, null, '', 0));
    slotList.add(Slot(2, SlotStatus.Available, null, '', 0));
    slotList.add(Slot(3, SlotStatus.Available, null, '', 0));
    Event newEvent = new Event(
        id,
        eventCode,
        eventName,
        clubId,
        ownerId,
        ownerName,
        createdDate,
        createdTime,
        eventStatus,
        slotList,
        timestamp,
        ["[]", "[]", "[]"]);
    SlotBook newSB =
        new SlotBook('', '', timestamp, 0, ownerId, ownerName, false);

    await eManager.createEventNDefaultSlotBook(newEvent, newSB).then((res) {
      if (res) {
        Global.showToastMessage(context: context, msg: 'Successfully added');

        Navigator.pop(context, newEvent);
      } else {
        Global.showToastMessage(
            context: context, msg: 'Something went wrong in the server side');
      }
    });
    Global.dismissLoading();
  }

  getUserData() {
    var _ownerId = SessionManager.getUserId();
    var _ownerName = SessionManager.getUserName();
    DateTime now = new DateTime.now();

    var _createdDate =
        DateUtils.getTimeStringWithFormat(dateTime: now, format: DateFormat);
    var _createdTime = '${now.hour}:${now.minute + 5}';
    var _eventStatus = EventStatus.OPENED;

    setState(() {
      ownerId = _ownerId;
      ownerName = _ownerName;
      createdDate = _createdDate;
      createdTime = _createdTime;
      eventStatus = _eventStatus;
    });
  }

  handleSelectTime(selTime) {
    int hour = selTime.hour;
    int min = selTime.minute;

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
  void initState() {
    super.initState();
    clubName = widget.myClubInfoList[0]['club_info'].name;
    clubId = widget.myClubInfoList[0]['club_info'].id;

    selectedTime = new TimeOfDay(
        hour: TimeOfDay.now().hour, minute: TimeOfDay.now().minute + 5);
    getUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget customCupertinoPicker() {
    return CupertinoPicker.builder(
      magnification: 1.2,
      backgroundColor: Colors.white,
      itemExtent: 50,
      onSelectedItemChanged: (int index) {
        setState(() {
          clubName = widget.myClubInfoList[index]['club_info'].name;
          clubId = widget.myClubInfoList[index]['club_info'].id;
        });
      },
      itemBuilder: (context, index) {
        return Text(widget.myClubInfoList[index]['club_info'].name,
            style: TextStyle(color: Colors.black));
      },
      childCount: widget.myClubInfoList.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.orange,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text("Add New Event",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))),
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
                  'Select club',
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
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                height: 200,
                                child: customCupertinoPicker(),
                              );
                            });
                      },
                      child: Center(
                          child: Text(
                        clubName == '' ? 'select the club name' : clubName,
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
                                firstDate: DateTime(DateTime.now().year,
                                    DateTime.now().month, DateTime.now().day))
                            .then((DateTime dateTime) {
                          if (dateTime != null) {
                            setState(() {
                              this.dom = dateTime;
                              print("${DateUtils.getMiliseconds(this.dom)}\n");
                              this.createdDate =
                                  DateUtils.getTimeStringWithFormat(
                                      dateTime: dateTime, format: DateFormat);
                            });
                          }
                        });
                      },
                      child: Center(
                          child: Text(
                        '$createdDate',
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
                SizedBox(width: 8),
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
                        '$createdTime',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      )),
                    ),
                  ),
                )
              ]),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 2.0,
                color: Colors.grey,
              ),
              SizedBox(
                height: 10,
              ),
              CustomTextField(
                iconData: Icons.confirmation_number,
                hintText: 'Enter your eventCode',
                onChanged: (value) {
                  this.eventCode = value;
                },
                initialValue: eventCode,
                isKeyboardNumber: true,
              ),
              CustomTextField(
                  iconData: Icons.room_service,
                  hintText: 'Enter your eventName',
                  onChanged: (value) {
                    this.eventName = value;
                  },
                  initialValue: eventName),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 2.0,
                color: Colors.grey,
              ),
              SizedBox(
                height: 10,
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
                text: 'Add',
                onPressed: onSubmit,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
