import 'package:eventbooking/common/custom_progress_dialogue.dart';
import 'package:eventbooking/firebase_services/EventManager.dart';
import 'package:eventbooking/models/Event.dart';
import 'package:eventbooking/models/Slot.dart';
import 'package:eventbooking/utils/DateUtils.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

final Color discountBackgroundColor = Color(0xFFFFE080);
final Color flightBorderColor = Color(0xFFEFE6E6);
final Color chipBackgroundColor = Color(0xFFFFFFFF);

final Color openedColor = Color(0xFFFFFFFF);
final Color lockedColor = Colors.white30;
final Color cancelledColor = Color(0xFFfcad8b);

final listCntLimit = 10;

ThemeData appTheme =
    ThemeData(primaryColor: Color(0xFFF3791A), fontFamily: 'Oxygen');

class HistoryScreen extends StatefulWidget {
  HistoryScreen();

  @override
  HistoryScreenState createState() {
    return HistoryScreenState();
  }
}

class HistoryScreenState extends State<HistoryScreen>
    with WidgetsBindingObserver {
  static HistoryScreenState _sharedInstance;

  static HistoryScreenState getInstance() {
    return _sharedInstance;
  }

  List<Event> eventList = [];

  HistoryScreenState();
  List<String> clubIds;
  String userId = '';
  CustomProgressDialog proDiag;
  SlidableController slidableController;

  @override
  void initState() {
    super.initState();
    userId = SessionManager.getUserId();
    clubIds = SessionManager.getMemberClubIds();
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
      int nowTs = DateUtils.getMiliseconds(new DateTime.now());
      eventList =
          await EventManager.getEventHistoryList(nowTs, limit: listCntLimit);
    } catch (e) {
      print(e);
    }
    Global.dismissLoading();

    if (eventList.length == 0) {
      Global.showToastMessage(
          context: context, msg: 'Not Found Events History');
    } else {
      this.setState(() {
        this.eventList = eventList;
      });
    }
  }

  final warningLabel = Center(
      child: Padding(
    padding: EdgeInsets.all(30),
    child: Text(
        'Only club member can create and book events. Please join a club',
        style: TextStyle(
            fontSize: 20, height: 1.4, color: Colors.deepOrangeAccent)),
  ));

  @override
  Widget build(BuildContext context) {
    proDiag = new CustomProgressDialog(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange,
        title: Text(
          "Event History",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
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
                    return EventItem(
                        eventInfo: eventList[index], userId: userId);
                  },
                )
              ],
            ),
          ),
          SizedBox(height: 10)
        ]),
      ),
    );
  }
}

class EventItem extends StatelessWidget {
  int emptyIdToBook = -1;
  final Event eventInfo;
  final String userId;
  int totalSlotCnt = 4;
  int availableSlotCnt = 0;
  List<Slot> slotList;
  String ownerId = '';
  EventStatus eventStatus;
  Axis direction;

  EventItem({this.eventInfo, this.userId, this.direction}) {
    slotList = eventInfo.slotList;
    ownerId = this.eventInfo.ownerId;
    eventStatus = this.eventInfo.eventStatus;
    for (Slot slot in slotList) {
      if (slot.status == SlotStatus.Available) {
        availableSlotCnt++;
        emptyIdToBook == -1 ? slot.id : emptyIdToBook;
      }
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
    return Card(
        elevation: 5,
        margin: EdgeInsets.only(top: 10, bottom: 10),
        color: cancelledColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: new InkWell(
            onTap: () {},
            child: ListTile(
              contentPadding: EdgeInsets.all(4),
              leading: Container(
                padding: EdgeInsets.only(top: 30, left: 3),
                child: Icon(
                  Icons.lock,
                  color: Colors.black,
                  size: 40,
                ),
              ),
              title: Text(
                'Name: ${eventInfo.name}',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: Colors.black87, width: 2))),
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
                } else {}
              },
            )));
  }
}
