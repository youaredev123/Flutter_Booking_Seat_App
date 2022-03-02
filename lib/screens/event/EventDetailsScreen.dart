import 'package:eventbooking/common/index.dart';
import 'package:eventbooking/firebase_services/EventManager.dart';
import 'package:eventbooking/firebase_services/SlotBookManager.dart';
import 'package:eventbooking/models/index.dart';
import 'package:eventbooking/screens/event/EditEventScreen.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:eventbooking/utils/resources.dart';
import 'package:flutter/material.dart';

enum InputAction { CANCEL, OK }

class EventDetailsScreen extends StatefulWidget {
  EventDetailsScreen(this.eventInfo);

  final Event eventInfo;

  @override
  EventDetailsScreenState createState() {
    return EventDetailsScreenState(eventInfo: this.eventInfo);
  }
}

class EventDetailsScreenState extends State<EventDetailsScreen> {
  static EventDetailsScreenState _sharedInstance;

  static EventDetailsScreenState getInstance() {
    return _sharedInstance;
  }

  EventDetailsScreenState({this.eventInfo});

  double opacity = 0.5;

  Event eventInfo;
  int numSeats = 0;
  int selectedId = -1;
  String userName;
  String userId;

  bool isLocked = false;
  bool isOwner = false;
  bool isCancelled = false;
  bool isOpened = true;

  String inputUserName = '';

  @override
  void initState() {
    super.initState();
    _sharedInstance = this;

    userName = SessionManager.getUserName();
    userId = SessionManager.getUserId();

    isOwner = eventInfo.ownerId == userId ? true : false;

    switch (eventInfo.eventStatus) {
      case EventStatus.CANCELLED:
        isCancelled = true;
        isLocked = false;
        isOpened = false;
        break;
      case EventStatus.OPENED:
        isCancelled = false;
        isLocked = false;
        isOpened = true;
        break;
      case EventStatus.LOCKED:
        isCancelled = false;
        isLocked = true;
        isOpened = false;
    }
    print('=====> $userName, $userId,$isLocked}');
  }

  handleSwitch(val) async {
    if (val) {
      setState(() {
        eventInfo.eventStatus = EventStatus.LOCKED;
      });
      Global.showLoading();
      await EventManager.lockEvent(eventInfo.id);
      Global.dismissLoading();
    } else {
      setState(() {
        eventInfo.eventStatus = EventStatus.OPENED;
      });
      Global.showLoading();
      await EventManager.reopenEvent(eventInfo.id);
      Global.dismissLoading();
    }

    setState(() {
      this.eventInfo = eventInfo;
      isLocked = val;
    });
  }

  bool isAlreadyBooked() {
    bool _alreadyBooked = false;
    for (var i = 0; i < eventInfo.slotList.length; i++) {
      if (eventInfo.slotList[i].userId == this.userId) {
        _alreadyBooked = true;
        break;
      }
    }
    return _alreadyBooked;
  }

  int countAvailableSlot() {
    int _cnt = 0;
    eventInfo.slotList.forEach((slot) {
      if (slot.status != SlotStatus.Booked) _cnt++;
    });
    return _cnt;
  }

  handleBooking() async {
    if (selectedId != -1) {
      int _availableCnt = countAvailableSlot();
      if (isAlreadyBooked()) {
        _asyncInputDialog(context, eventInfo);
      } else {
        Global.showLoading();

        eventInfo.slotList[selectedId].status = SlotStatus.Booked;
        eventInfo.slotList[selectedId].userId = userId;
        eventInfo.slotList[selectedId].userName = userName;

        if (_availableCnt - 1 == 0) {
          eventInfo.eventStatus = EventStatus.LOCKED;
          isLocked = true;
          isOpened = false;
          isCancelled = false;
        }

        SlotBook newSB = new SlotBook('', eventInfo.id, eventInfo.timestamp,
            selectedId, userId, userName, false);
        var res = await EventManager.bookSlotNCreateSlotBook(
            eventInfo, eventInfo.slotList, newSB);
        if (res) {
          setState(() {
            this.eventInfo = eventInfo;
            selectedId = -1;
            this.isLocked = isLocked;
            this.isOpened = isOpened;
            this.isCancelled = isCancelled;
          });
        } else {
          Global.showToastMessage(
              context: context, msg: 'Something went wrong.Please try again');
        }
        Global.dismissLoading();
      }
    }
  }

  int findOwnerCandidate(int selId) {
    int _candidateId = 4;
    eventInfo.slotList.forEach((slot) {
      if (slot.status == SlotStatus.Booked &&
          slot.id != null &&
          slot.id != '' &&
          _candidateId > slot.id &&
          slot.id != selId) {
        _candidateId = slot.id;
      }
    });
    return _candidateId;
  }

  void handleRetrieve(BuildContext context, int id) async {
    Global.showLoading();

    if (eventInfo.ownerId == eventInfo.slotList[id].userId) {
      int _candidateId = findOwnerCandidate(id);
      if (_candidateId == Global.eventMemberCnt) {
        await EventManager.deleteEvent(eventInfo.id);

        await SlotBookManager.cancelSlotBook(
            eventInfo.id, eventInfo.slotList[id].userId, id);
        Navigator.pop(context, eventInfo.id);
      } else {
        eventInfo.ownerId = eventInfo.slotList[_candidateId].userId;
        eventInfo.ownerName = eventInfo.slotList[_candidateId].userName;
        eventInfo.eventStatus = EventStatus.OPENED;

        Slot temp = eventInfo.slotList[_candidateId];
        temp.id = 0;
        eventInfo.slotList[0] = temp;
        eventInfo.slotList[_candidateId] =
            Slot(_candidateId, SlotStatus.Available, null, "", 0);
        isCancelled = false;
        isLocked = false;
        isOpened = true;
        await EventManager.cancelBookingNUpdateEvent(eventInfo);
        await SlotBookManager.cancelSlotBook(
            eventInfo.id, eventInfo.slotList[id].userId, id);
      }
    } else {
      eventInfo.slotList[id].status = SlotStatus.Available;
      eventInfo.slotList[id].userName = '';
      eventInfo.slotList[id].userId = null;
      await EventManager.cancelBookingNUpdateEvent(eventInfo);
      await SlotBookManager.cancelSlotBook(
          eventInfo.id, eventInfo.slotList[id].userId, id);
    }

    setState(() {
      this.eventInfo = eventInfo;
      this.isLocked = isLocked;
      this.isCancelled = isCancelled;
      this.isOpened = isOpened;
    });
    Global.dismissLoading();
  }

  @override
  void dispose() {
    super.dispose();
    if (this.selectedId != -1) {
      this.eventInfo.slotList[selectedId].status = SlotStatus.Available;
      this.selectedId = -1;
    }
  }

  void handleSlotBookWithOnlyName(String val, Event eventInfo) async {
    Global.showLoading();
    inputUserName = val;
    eventInfo.slotList[selectedId].status = SlotStatus.Booked;
    eventInfo.slotList[selectedId].userId = null;
    eventInfo.slotList[selectedId].userName = inputUserName;
    int availSlotCnt = countAvailableSlot();

    if (availSlotCnt - 1 == 0) {
      eventInfo.eventStatus = EventStatus.LOCKED;
      isLocked = true;
      isOpened = false;
      isCancelled = false;
    }

    SlotBook newSB = new SlotBook('', eventInfo.id, eventInfo.timestamp,
        selectedId, '', inputUserName, false);

    await EventManager.bookSlotNCreateSlotBook(
        eventInfo, eventInfo.slotList, newSB);

    Global.dismissLoading();
    setState(() {
      this.eventInfo = eventInfo;
      selectedId = -1;
      this.isLocked = isLocked;
      this.isOpened = isOpened;
      this.isCancelled = isCancelled;
    });
  }

  Future<InputAction> _asyncInputDialog(
      BuildContext context, Event eventInfo) async {
    return showDialog<InputAction>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Member Name'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'Member Name', hintText: 'input name'),
                onChanged: (value) {
                  inputUserName = value;
                },
                onSubmitted: (value) {
                  setState(() {
                    inputUserName = value;
                  });
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              color: Colors.lightGreen,
              child: const Text('Cancel',
                  style: TextStyle(fontSize: 15, color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(InputAction.CANCEL);
              },
            ),
            FlatButton(
              color: Colors.lightBlue,
              child: const Text('OK',
                  style: TextStyle(fontSize: 15, color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(InputAction.OK);
                handleSlotBookWithOnlyName(inputUserName, eventInfo);
              },
            ),
          ],
        );
      },
    );
  }

  go2EditScreen() async {
    var res = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditEventScreen(this.eventInfo)));
    if (res == null) {
      return;
    }
    if (res is Event) {
      setState(() {
        this.eventInfo = res;
      });
    }
  }

  void handleSelect(BuildContext context, int id) async {
    {
      if (!isLocked) {
        if (eventInfo.slotList[id].status == SlotStatus.Booked &&
            (eventInfo.ownerId == userId ||
                eventInfo.slotList[id].userId == this.userId ||
                eventInfo.slotList[id].userId.isEmpty)) {
          ConfirmAction res = await _asyncConfirmDialog(context);
          if (res == ConfirmAction.ACCEPT) {
            handleRetrieve(context, id);
          } else {
            return;
          }
        } else if (eventInfo.slotList[id].status != SlotStatus.Booked) {
          if (id == selectedId) {
            setState(() {
              eventInfo.slotList[id].status = SlotStatus.Available;
              opacity = 0.5;
              selectedId = -1;
            });
          } else {
            setState(() {
              if (selectedId != -1)
                eventInfo.slotList[selectedId].status = SlotStatus.Available;
              eventInfo.slotList[id].status = SlotStatus.InProgress;
              opacity = 1.0;
              selectedId = id;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          centerTitle: true,
          title: Text(
            eventInfo.name ?? 'Select the seat',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18.0),
          ),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              ClipPath(
                clipper: CustomShapeClipper(),
                child: Container(
                  color: Colors.orange,
                  height: 0,
                ),
              ),
              Column(
                children: <Widget>[
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Created time: ${eventInfo.createdDate}, ${eventInfo.createdTime}',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  )),
                  Container(
                    height: 100,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          SeatTypeItem(bookedColor, 'Booked'),
                          SeatTypeItem(availableColor, 'Available'),
                          SeatTypeItem(inProgressColor, 'in progress'),
                        ]),
                  ),
                  isCancelled ? Container() : switchLock(),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.all(10),
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: eventInfo.slotList.length,
                      itemBuilder: (context, index) {
                        return SlotItem(
                            slotInfo: eventInfo.slotList[index],
                            onSelected: (id) => handleSelect(context, id));
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  isOwner
                      ? CustomButton(
                          text: 'Edit',
                          buttonWidth: 200,
                          onPressed: () {
                            go2EditScreen();
                          },
                        )
                      : Container(),
                  CustomButton(
                      text: 'Book',
                      opacity: opacity,
                      onPressed: () {
                        if (isLocked && eventInfo.ownerId != this.userId) {
                          Global.showToastMessage(
                              context: context,
                              msg:
                                  'You can\'t book because the event is locked');
                        } else {
                          handleBooking();
                        }
                      }),
                ],
              ),
            ],
          ),
        ));
  }

  Widget switchLock() {
    return Center(
        child: Container(
      height: 40,
      decoration: BoxDecoration(boxShadow: [
        new BoxShadow(
          color: Colors.white,
          blurRadius: 10.0,
        ),
      ], borderRadius: BorderRadius.all(Radius.circular(5))),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(isOwner ? 'Switch room status' : "Room status: ",
              style: TextStyle(fontSize: 16, color: Colors.black)),
          isOwner
              ? Switch(
                  value: isLocked,
                  activeColor: Colors.red,
                  inactiveThumbColor: Colors.lightBlue,
                  onChanged: (val) {
                    handleSwitch(val);
                  })
              : Text('     '),
          Text(isLocked ? 'Locked' : 'Opened',
              style: TextStyle(
                  fontSize: 16,
                  color: isLocked ? Colors.red : Colors.lightBlue)),
        ],
      ),
    ));
  }
}

class SlotItem extends StatelessWidget {
  SlotItem({this.slotInfo, this.onSelected});

  final Slot slotInfo;
  final ValueChanged<int> onSelected;

  Color buildBgColor() {
    var status = slotInfo.status;
    if (status == SlotStatus.Booked) {
      return bookedColor;
    } else if (status == SlotStatus.Available) {
      return availableColor;
    } else {
      return inProgressColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5,
        color: buildBgColor(),
        margin: EdgeInsets.only(top: 10, bottom: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: InkWell(
            onTap: () {
              onSelected(slotInfo.id);
            },
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        '${slotInfo.id + 1}',
                        style: TextStyle(fontSize: 32, color: Colors.black87),
                      ),
                    ),
                    Expanded(
                      child: true
                          ? Column(
                              children: <Widget>[
                                SizedBox(height: 5),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Expanded(
                                        child: Center(
                                      child: slotInfo.status ==
                                              SlotStatus.Booked
                                          ? Text('Booker: ${slotInfo.userName}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87))
                                          : Text('Free',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87)),
                                    ))
                                  ],
                                ),
                                SizedBox(height: 5),
                              ],
                            )
                          : Text(''),
                    ),
                  ],
                ),
              ),
            )));
  }
}

class SeatTypeItem extends StatelessWidget {
  SeatTypeItem(this.color, this.type);

  final Color color;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: color, width: 1.0)),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            type,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }
}

enum ConfirmAction { CANCEL, ACCEPT }

Future<ConfirmAction> _asyncConfirmDialog(BuildContext context) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Cancel booking'),
        content: const Text('Do you really want to cancel the booking?'),
        actions: <Widget>[
          FlatButton(
            child: const Text('CANCEL'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.CANCEL);
            },
          ),
          FlatButton(
            child: const Text('ACCEPT'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.ACCEPT);
            },
          )
        ],
      );
    },
  );
}
