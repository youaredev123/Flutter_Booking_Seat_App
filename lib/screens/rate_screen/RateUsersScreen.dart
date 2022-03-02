import 'package:eventbooking/common/custom_button.dart';
import 'package:eventbooking/firebase_services/EventManager.dart';
import 'package:eventbooking/firebase_services/RateManager.dart';
import 'package:eventbooking/firebase_services/SlotBookManager.dart';
import 'package:eventbooking/models/index.dart';
import 'package:eventbooking/screens/event/AddEventScreen.dart';
import 'package:eventbooking/screens/rate_screen/button_pair_widget.dart';
import 'package:eventbooking/utils/DateUtils.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:eventbooking/utils/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'seat_type_item_widget.dart';

enum RegisterStatus { Rater, Registered, Unregistered, Empty }

class RateUsersScreen extends StatefulWidget {
  final Event eventInfo;
  final String slotBookId;
  final EventAddListener _listener;
  final List<Map<String, dynamic>> myClubInfoList;
  @override
  RateUsersScreenState createState() => RateUsersScreenState();

  RateUsersScreen(
      this.eventInfo, this.slotBookId, this._listener, this.myClubInfoList);
}

class RateUsersScreenState extends State<RateUsersScreen> {
  var _ratingController = TextEditingController();
  List<double> _ratings = [0, 0, 0, 0];
  IconData _selectedIcon;
  String userId;
  String eventId;
  List<Slot> slotList;
  bool isAdmin = false;

  List<String> _autoRateArray;
  Event _eventInfo;

  List<int> _list;

  @override
  void initState() {
    _ratingController.text = "3.0";
    eventId = widget.eventInfo.id;
    slotList = widget.eventInfo.slotList;
    userId = SessionManager.getUserId();
    isAdmin = userId == widget.eventInfo.ownerId;
    _eventInfo = widget.eventInfo;

    _list = [0, 1, 2];
    _autoRateArray = _eventInfo.autoRateArray;
    super.initState();
  }

  List<String> handleAutoRate(List<String> list) {
    List<String> tempList = list;
    String temp;
    for (int i = 0; i < list.length; i++) {
      for (int j = i + 1; j < list.length; j++) {
        if (list[i] == "[]" || list[i] == "[0,0]") {
          temp = list[i];
          list[i] = list[j];
          list[j] = temp;
        }
      }
    }
    for (int i = 0; i < list.length; i++) {
      if (list[i] == "[]") list[i] = "[0,0]";
    }
    return list;
  }

  handleRate() async {
    Global.showLoading();

    Rate newRate;
    int nowTs = DateUtils.getMiliseconds(new DateTime.now());
    try {
      for (int i = 0; i < slotList.length; i++) {
        if (findRegisterStatus(i) == RegisterStatus.Registered) {
          newRate = new Rate(
              '', eventId, userId, slotList[i].userId, nowTs, _ratings[i]);

          await RateManager.createRate(newRate);
        }
      }

      _autoRateArray = handleAutoRate(_autoRateArray);
      await SlotBookManager.updateRate(widget.slotBookId, true);

      await EventManager.updateEvent(_eventInfo);
      Global.dismissLoading();

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AddEventScreen(
                    customListener: widget._listener,
                    myClubInfoList: widget.myClubInfoList,
                  )));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        appBarTheme: AppBarTheme(
          textTheme: TextTheme(
            title: Theme.of(context).textTheme.title.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ),
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(widget.eventInfo.name ?? 'Rating Users'),
          ),
          body: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          'created time: ${widget.eventInfo.createdDate}, ${widget.eventInfo.createdTime}',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                    Container(
                      height: 100,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            SeatTypeItem(raterColor, 'Current Rater'),
                            SeatTypeItem(registeredUserColor, 'Registered'),
                            SeatTypeItem(unRegisteredUserColor, 'Unregistered'),
                            SeatTypeItem(emptyColor, 'Empty'),
                          ]),
                    ),
                    Visibility(
                      visible: widget.eventInfo.ownerId == userId,
                      child: Column(
                        children: <Widget>[
                          RatingItem(
                            key: Key("0"),
                            slotList: this.slotList,
                            index: 0,
                            ratings: this._ratings,
                            rateFunc: this.rateFunc,
                          ),
                          Container(
                            height: 260,
                            child: ReorderableListView(
                              padding: EdgeInsets.all(8),
                              children: _list
                                  .map((item) => RatingItem(
                                        key: Key((item + 1).toString()),
                                        slotList: this.slotList,
                                        index: item + 1,
                                        ratings: this._ratings,
                                        rateFunc: this.rateFunc,
                                      ))
                                  .toList(),
                              onReorder: (int start, int current) {
                                if (start < current) {
                                  int end = current - 1;
                                  int startItem = _list[start];
                                  int i = 0;
                                  int local = start;
                                  do {
                                    _list[local] = _list[++local];
                                    i++;
                                  } while (i < end - start);
                                  _list[end] = startItem;
                                } else if (start > current) {
                                  int startItem = _list[start];
                                  for (int i = start; i > current; i--) {
                                    _list[i] = _list[i - 1];
                                  }
                                  _list[current] = startItem;
                                }
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: widget.eventInfo.ownerId != userId,
                      child: Column(
                        children: <Widget>[
                          _ratingItem(0),
                          _ratingItem(1),
                          _ratingItem(2),
                          _ratingItem(3),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        ButtionPair(0, onConfirmed, isAdmin, _autoRateArray),
                        ButtionPair(1, onConfirmed, isAdmin, _autoRateArray),
                        ButtionPair(2, onConfirmed, isAdmin, _autoRateArray),
                      ],
                    ),
                    CustomButton(
                      text: 'Rate',
                      onPressed: handleRate,
                    ),
                    SizedBox(
                      height: 42,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void rateFunc(int index, double rMark) {
    setState(() {
      this._ratings[index] = rMark;
    });
  }

  RegisterStatus findRegisterStatus(index) {
    Slot _slotInfo = slotList[index];
    if (_slotInfo.userId == userId) return RegisterStatus.Rater;
    if (_slotInfo.userId != "" && _slotInfo.userId != null)
      return RegisterStatus.Registered;
    if (_slotInfo.userName != "" && _slotInfo.userName != null)
      return RegisterStatus.Unregistered;
    return RegisterStatus.Empty;
  }

  onConfirmed(List list, int index) {
    setState(() {
      this._autoRateArray[index] =
          "[" + list[0].toString() + "," + list[1].toString() + "]";
    });
  }

  Color colorByRegisterStatus(RegisterStatus _regStatus) {
    Color _itemColor;
    switch (_regStatus) {
      case RegisterStatus.Rater:
        _itemColor = raterColor;
        break;

      case RegisterStatus.Registered:
        _itemColor = registeredUserColor;
        break;
      case RegisterStatus.Unregistered:
        _itemColor = unRegisteredUserColor;
        break;
      case RegisterStatus.Empty:
        _itemColor = emptyColor;
        break;
      default:
        _itemColor = registeredUserColor;
        break;
    }
    return _itemColor;
  }

  Widget _ratingItem(index) {
    var _registerStatus = findRegisterStatus(index);
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            margin: EdgeInsets.all(10),
            child: Card(
              elevation: 10,
              color: colorByRegisterStatus(_registerStatus),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding:
                        EdgeInsets.only(top: 12, right: 8, left: 8, bottom: 4),
                    child: Text(
                      'Booker: ${_registerStatus == RegisterStatus.Empty ? 'Free' : slotList[index].userName}',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: _registerStatus == RegisterStatus.Registered
                        ? _ratingBar(index)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ratingBar(int index) {
    return RatingBar(
      initialRating: _ratings[index],
      unratedColor: Colors.grey[200],
      itemSize: 30,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        _selectedIcon ?? Icons.star,
        color: Colors.orange,
      ),
      onRatingUpdate: (rating) {
        rateFunc(index, rating);
      },
    );
  }
}

class RatingItem extends StatefulWidget {
  final Key key;
  final List<Slot> slotList;
  final int index;
  final List<double> ratings;
  final Function rateFunc;
  RatingItem({this.key, this.slotList, this.index, this.ratings, this.rateFunc})
      : super(key: key);
  @override
  _RatingItemState createState() => _RatingItemState();
}

class _RatingItemState extends State<RatingItem> {
  var _registerStatus;
  List<Slot> slotList;
  int index;
  String userId;
  List<double> _ratings = [];

  @override
  void initState() {
    super.initState();
    slotList = widget.slotList;

    index = widget.index;

    userId = SessionManager.getUserId();
    _ratings = widget.ratings;
    _registerStatus = findRegisterStatus(index);
  }

  RegisterStatus findRegisterStatus(index) {
    Slot _slotInfo = slotList[index];

    if (_slotInfo.userId == userId) return RegisterStatus.Rater;
    if (_slotInfo.userId != "" && _slotInfo.userId != null)
      return RegisterStatus.Registered;
    if (_slotInfo.userName != "" && _slotInfo.userName != null)
      return RegisterStatus.Unregistered;
    return RegisterStatus.Empty;
  }

  Color colorByRegisterStatus(RegisterStatus _regStatus) {
    Color _itemColor;
    switch (_regStatus) {
      case RegisterStatus.Rater:
        _itemColor = raterColor;
        break;

      case RegisterStatus.Registered:
        _itemColor = registeredUserColor;
        break;
      case RegisterStatus.Unregistered:
        _itemColor = unRegisteredUserColor;
        break;
      case RegisterStatus.Empty:
        _itemColor = emptyColor;
        break;
      default:
        _itemColor = registeredUserColor;
        break;
    }
    return _itemColor;
  }

  Widget _ratingBar(int index) {
    return RatingBar(
      initialRating: _ratings[index],
      allowHalfRating: true,
      unratedColor: Colors.grey[200],
      itemSize: 30,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.orange,
      ),
      onRatingUpdate: (rating) {
        widget.rateFunc(index, rating);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            height: _registerStatus == RegisterStatus.Registered ? 90 : 60,
            margin: EdgeInsets.all(10),
            child: Card(
              elevation: 10,
              color: colorByRegisterStatus(_registerStatus),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding:
                        EdgeInsets.only(top: 12, right: 8, left: 8, bottom: 4),
                    child: Text(
                      'Booker: ${_registerStatus == RegisterStatus.Empty ? 'Free' : slotList[index].userName}',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: _registerStatus == RegisterStatus.Registered
                        ? _ratingBar(index)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
