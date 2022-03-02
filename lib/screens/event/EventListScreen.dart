import 'package:eventbooking/firebase_services/ClubManager.dart';
import 'package:eventbooking/firebase_services/ClubToUserManager.dart';
import 'package:eventbooking/firebase_services/EventManager.dart';
import 'package:eventbooking/firebase_services/SlotBookManager.dart';
import 'package:eventbooking/models/index.dart';
import 'package:eventbooking/screens/event/AddEventScreen.dart';
import 'package:eventbooking/screens/event/EventDetailsScreen.dart';
import 'package:eventbooking/screens/rate_screen/RateUsersScreen.dart';
import 'package:eventbooking/utils/Constant.dart';
import 'package:eventbooking/utils/DateUtils.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:eventbooking/utils/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

enum ConfirmAction { CANCEL, ACCEPT }
enum InputAction { CANCEL, OK }

class EventListScreen extends StatefulWidget {
  EventListScreen();

  @override
  EventListScreenState createState() {
    return EventListScreenState();
  }
}

class EventListScreenState extends State<EventListScreen>
    with WidgetsBindingObserver, EventAddListener {
  SlidableController slidableController;
  List<Event> eventList = [];
  String userId = '';
  String inputUserName = '';
  EventListScreenState();
  List<String> clubIds;
  Animation<double> _rotationAnimation;
  Color _fabColor = Colors.blue;
  List<ClubToUser> _myClubToUserList;
  List<String> _myClubIdList = [];
  List<Map<String, dynamic>> _myClubInfoList = [];

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {
      _rotationAnimation = slideAnimation;
    });
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {
      _fabColor = isOpen ? Colors.green : Colors.blue;
    });
  }

  static EventListScreenState _sharedInstance;

  static EventListScreenState getInstance() {
    return _sharedInstance;
  }

  @override
  void initState() {
    super.initState();

    userId = SessionManager.getUserId();
    clubIds = SessionManager.getMemberClubIds();
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    _sharedInstance = this;
    WidgetsBinding.instance.addObserver(this);
    this.loadEventData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        loadEventData();
        break;
      default:
        break;
    }
  }

  loadEventData() async {
    Global.showLoading();
    try {
      this._myClubToUserList =
          await ClubToUserManager.getClubListByUserId(userId) ?? [];

      Map<String, dynamic> temp;

      for (int i = 0; i < _myClubToUserList.length; i++) {
        temp = new Map<String, dynamic>();
        temp['club_to_user'] = _myClubToUserList[i];
        temp['club_info'] =
            await ClubManager.getClubInfoById(_myClubToUserList[i].clubId);
        _myClubInfoList.add(temp);
      }

      List<String> clubIdList = [];
      clubIdList = _myClubToUserList.map((clubInfo) {
        return clubInfo.clubId;
      }).toList();

      clubIdList.sort((String a, String b) {
        return a.toLowerCase().compareTo(b.toLowerCase());
      });

      String tempStr = '';

      _myClubIdList = [];
      for (int j = 0; j < clubIdList.length; j++) {
        if (tempStr != clubIdList[j]) {
          _myClubIdList.add(clubIdList[j]);
        }
        tempStr = clubIdList[j];
      }

      int nowTs = DateUtils.getMiliseconds(new DateTime.now());
      eventList = await EventManager.getEventList(nowTs);
      eventList.removeWhere((eve) => !_myClubIdList.contains(eve.clubId));
    } catch (e) {
      print(e);
    }
    if (eventList.length == 0) {
      Global.showToastMessage(context: context, msg: 'Not Found Booked Events');
      setState(() {
        _myClubToUserList;
        _myClubInfoList;
        this._myClubIdList = _myClubIdList;
      });
    } else {
      setState(() {
        this.eventList = eventList;
        _myClubToUserList;
        _myClubInfoList;
        this._myClubIdList = _myClubIdList;
      });
    }
    Global.dismissLoading();
  }

  void handleSlotBookWithOnlyName(
      String val, Event eventInfo, int availSlotCnt, int willBookId) async {
    List<Slot> _slotList = eventInfo.slotList;
    inputUserName = val;
    if (willBookId != -1) {
      _slotList[willBookId].status = SlotStatus.Booked;
      _slotList[willBookId].userName = inputUserName;
      if (availSlotCnt - 1 == 0) eventInfo.eventStatus = EventStatus.LOCKED;
      if (availSlotCnt == 4) {
        eventInfo.ownerId = userId;
        eventInfo.ownerName = SessionManager.getUserName();
      }
    }
    SlotBook newSB = new SlotBook('', eventInfo.id, eventInfo.timestamp,
        willBookId, '', inputUserName, false);
    var res =
        await EventManager.bookSlotNCreateSlotBook(eventInfo, _slotList, newSB);
    if (res) {
      await loadEventData();
      inputUserName = '';
    } else {
      Global.showToastMessage(
          context: context, msg: 'Something went wrong. Please try again');
    }

    return;
  }

  Future<InputAction> _asyncInputDialog(BuildContext context, Event eventInfo,
      int availSlotCnt, int willBookId) async {
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
                handleSlotBookWithOnlyName(
                    inputUserName, eventInfo, availSlotCnt, willBookId);
              },
            ),
          ],
        );
      },
    );
  }

  go2AddEventScreen() async {
    var res = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddEventScreen(
                customListener: this, myClubInfoList: _myClubInfoList)));
    if (res == null) return;
    if (res is Event) {
      addEvent(res);
    }
  }

  Future<ConfirmAction> _ratingConfirmDialog(
      BuildContext context, Event willRateEventInfo, String slotBookId) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: customButtonShape,
          title: Text('Rate Setting'),
          content: const Text(
            'Do you want to rate your previous booking ?',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          actions: <Widget>[
            Align(
              alignment: Alignment.bottomLeft,
              child: FlatButton(
                color: Colors.grey,
                child: const Text('Cancel',
                    style: TextStyle(fontSize: 15, color: Colors.white)),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ),
            FlatButton(
              color: Colors.lightGreen,
              child: const Text('Not Now',
                  style: TextStyle(fontSize: 15, color: Colors.white)),
              onPressed: () async {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
                go2AddEventScreen();
              },
            ),
            FlatButton(
              color: Colors.lightBlue,
              child: const Text('YES',
                  style: TextStyle(fontSize: 15, color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.ACCEPT);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RateUsersScreen(willRateEventInfo,
                            slotBookId, this, this._myClubInfoList)));
              },
            )
          ],
        );
      },
    );
  }

  final warningLabel = Center(
      child: Padding(
    padding: EdgeInsets.all(30),
    child: Text(
        'Only club member can create and book events. Please join a club',
        style: TextStyle(
            fontSize: 20, height: 1.4, color: Colors.deepOrangeAccent)),
  ));
  addEvent(Event newEvent) {
    setState(() {
      eventList.add(newEvent);
    });
  }

  @override
  Widget build(BuildContext context) {
    handleAddEventBtnClick() async {
      Global.showLoading();
      int nowTs = DateUtils.getMiliseconds(new DateTime.now());

      SlotBook _willRateBookingInfo =
          await SlotBookManager.findWillRateBookingInfo(userId, nowTs);

      if (_willRateBookingInfo == null) {
        Global.dismissLoading();
        await go2AddEventScreen();
      } else {
        String _willRateEventId = _willRateBookingInfo.eventId;
        String _slotBookId = _willRateBookingInfo.id;
        Event _willRateEventInfo =
            await EventManager.getEventInfoById(_willRateEventId);
        Global.dismissLoading();
        if (_willRateEventInfo != null) {
          _ratingConfirmDialog(context, _willRateEventInfo, _slotBookId);
        }
      }
    }

    final topAppBar = AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.orange,
      centerTitle: true,
      title: Text(
        "Select the Event",
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      elevation: 0.1,
      actions: (_myClubIdList.length == 0)
          ? null
          : <Widget>[
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.add),
                tooltip: 'Add Event',
                onPressed: () {
                  handleAddEventBtnClick();
                },
              ),
            ],
    );

    void _showSnackBar(BuildContext context, String text) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
    }

    void handleSlideBook(
        context, Event eventInfo, availSlotCnt, willBookId) async {
      if (availSlotCnt == 0 || willBookId == -1) return;
      var _alreadyBooked = false;
      for (var i = 0; i < eventInfo.slotList.length; i++) {
        if (eventInfo.slotList[i].userId == this.userId) {
          _alreadyBooked = true;
          break;
        }
      }

      if (_alreadyBooked) {
        _asyncInputDialog(context, eventInfo, availSlotCnt, willBookId);
      } else {
        List<Slot> _slotList = eventInfo.slotList;
        String bookerName = SessionManager.getUserName();
        String bookerId = SessionManager.getUserId();

        if (willBookId != -1) {
          _slotList[willBookId].status = SlotStatus.Booked;
          _slotList[willBookId].userName = bookerName;
          _slotList[willBookId].userId = bookerId;
          if (availSlotCnt - 1 == 0) eventInfo.eventStatus = EventStatus.LOCKED;
          if (availSlotCnt == 4) {
            eventInfo.ownerId = bookerId;
            eventInfo.ownerName = bookerName;
          }
        }
        SlotBook newSB = new SlotBook('', eventInfo.id, eventInfo.timestamp,
            willBookId, bookerId, bookerName, false);

        bool res = await EventManager.bookSlotNCreateSlotBook(
            eventInfo, _slotList, newSB);
        if (res) {
          _showSnackBar(context, 'Book');
        } else {
          Global.showToastMessage(
              context: context, msg: 'Something went wrong. Please try again');
        }
      }
    }

    void handleSlideCancel(context, Event eventInfo) async {
      Global.showLoading();
      if (eventInfo.eventStatus == EventStatus.CANCELLED) {
        eventInfo.eventStatus = EventStatus.OPENED;
        await EventManager.reopenEvent(eventInfo.id);
      } else {
        eventInfo.eventStatus = EventStatus.CANCELLED;
        await EventManager.cancelEvent(eventInfo.id);
      }

      _showSnackBar(context,
          eventInfo.eventStatus == EventStatus.CANCELLED ? 'Reopen' : 'Cancel');
      Global.dismissLoading();
    }

    deleteEvent(String eventId) {
      setState(() {
        eventList.removeWhere((eve) => eve.id == eventId);
      });
    }

    Widget _getSlidableWithLists(BuildContext context, Event eventInfo,
        int availSlotCnt, int willBookId) {
      String _ownerId = eventInfo.ownerId;
      EventStatus _eventStatus = eventInfo.eventStatus;
      return Card(
        elevation: 5,
        margin: EdgeInsets.only(top: 10, bottom: 10),
        color: eventInfo.eventStatus == EventStatus.OPENED
            ? openedColor
            : eventInfo.eventStatus == EventStatus.CANCELLED
                ? cancelledColor
                : lockedColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Slidable(
          key: Key(eventInfo.name),
          controller: slidableController,
          actionPane: SlidableStrechActionPane(),
          actionExtentRatio: 0.3,
          child: VerticalListItem(eventInfo, userId, deleteEvent),
          actions: _eventStatus == EventStatus.OPENED
              ? <Widget>[
                  IconSlideAction(
                      caption: 'Book',
                      color: Colors.green,
                      icon: Icons.archive,
                      onTap: () => handleSlideBook(
                          context, eventInfo, availSlotCnt, willBookId)),
                ]
              : null,
          secondaryActions: _ownerId == userId
              ? <Widget>[
                  IconSlideAction(
                    caption: _eventStatus == EventStatus.CANCELLED
                        ? 'Reopen'
                        : 'Cancel',
                    color: Colors.red,
                    icon: _eventStatus == EventStatus.CANCELLED
                        ? Icons.open_with
                        : Icons.delete,
                    onTap: () => handleSlideCancel(context, eventInfo),
                  ),
                ]
              : null,
        ),
      );
    }

    final makeBody = SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: eventList.length,
                itemBuilder: (context, index) {
                  int availSlotCnt = 0;
                  int willBookId = -1;
                  for (Slot slot in eventList[index].slotList) {
                    if (slot.status == SlotStatus.Available) {
                      availSlotCnt++;
                      if (willBookId == -1) willBookId = slot.id;
                    }
                  }
                  return _getSlidableWithLists(
                      context, eventList[index], availSlotCnt, willBookId);
                },
              )
            ],
          ),
        ),
        SizedBox(height: 10)
      ]),
    );

    return Scaffold(
      appBar: topAppBar,
      body: makeBody,
    );
  }

  @override
  void onEventAdded() {
    loadEventData();
  }
}

class VerticalListItem extends StatelessWidget {
  final Event eventInfo;
  final String userId;
  final ValueChanged<String> deletEvent;
  VerticalListItem(this.eventInfo, this.userId, this.deletEvent);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
              ? Slidable.of(context)?.open()
              : Slidable.of(context)?.close(),
      child: Container(
        color: Colors.lightBlueAccent,
        child: EventItemCard(
            eventInfo: eventInfo, userId: userId, delFunc: deletEvent),
      ),
    );
  }
}

class EventItemCard extends StatelessWidget {
  int emptyIdToBook = -1;
  final Event eventInfo;
  final String userId;
  int totalBeds = 4;
  int availableSlotCnt = 0;
  List<Slot> slotList;
  String ownerId = '';
  EventStatus eventStatus;
  final ValueChanged<String> delFunc;
  EventItemCard({this.eventInfo, this.userId, this.delFunc}) {
    slotList = eventInfo.slotList;
    ownerId = this.eventInfo.ownerId;
    eventStatus = this.eventInfo.eventStatus;

    for (Slot slot in slotList) {
      if (slot.status == SlotStatus.Available) {
        availableSlotCnt++;
        if (emptyIdToBook == -1) emptyIdToBook = slot.id;
      }
    }
  }
  go2EventDetailScreen(BuildContext context, Event eventInfo) async {
    var res = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EventDetailsScreen(this.eventInfo)));
    if (res == null) return;
    if (res is String) {
      delFunc(res);
    }
  }

  Widget ExpandedWidget(index) {
    String _displayName = slotList[index].userName;
    if (_displayName == "" || _displayName == null) _displayName = 'Free';
    return Expanded(
      flex: 1,
      child: Padding(
          padding: EdgeInsets.only(left: 2.0),
          child: Text(_displayName,
              style: TextStyle(color: Colors.white, fontSize: 16))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(4),
      leading: Container(
        padding: EdgeInsets.only(top: 30, left: 3),
        child: Icon(
          eventInfo.eventStatus == EventStatus.LOCKED
              ? Icons.lock
              : eventInfo.eventStatus == EventStatus.CANCELLED
                  ? Icons.cancel
                  : Icons.lock_open,
          color: Colors.black,
          size: 40,
        ),
      ),
      title: Text(
        'Name: ${eventInfo.name}',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.black87, width: 2))),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Padding(
                      padding: EdgeInsets.only(left: 1.0, top: 5),
                      child: Text('Code: ${eventInfo.code}',
                          style: TextStyle(color: Colors.white))),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 5),
                      child: Text(
                          'Time: ${eventInfo.createdDate}, ${eventInfo.createdTime}',
                          style: TextStyle(color: Colors.white))),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: <Widget>[
              ExpandedWidget(0),
              ExpandedWidget(1),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: <Widget>[
              ExpandedWidget(2),
              ExpandedWidget(3),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                'Available: $availableSlotCnt/4',
                style: TextStyle(fontSize: 12),
              ),
            ],
          )
        ],
      ),
      onTap: () {
        if (eventStatus == EventStatus.CANCELLED && ownerId != userId) {
          return;
        } else {
          go2EventDetailScreen(context, this.eventInfo);
        }
      },
    );
  }
}
