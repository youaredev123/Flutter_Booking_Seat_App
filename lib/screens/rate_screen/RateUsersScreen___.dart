import 'package:eventbooking/common/custom_button.dart';
import 'package:eventbooking/firebase_services/RateManager.dart';
import 'package:eventbooking/firebase_services/SlotBookManager.dart';
import 'package:eventbooking/models/index.dart';
import 'package:eventbooking/utils/DateUtils.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:eventbooking/utils/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:eventbooking/screens/event/AddEventScreen.dart';
import 'package:reorderables/reorderables.dart';

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
  List<int> Ind = [0, 1, 2, 3];

  IconData _selectedIcon;
  String userId;
  String eventId;
  List<Slot> slotList;
  List<Widget> ratingItemList = [];
  List<Widget> _rows;
  void _onRReorder(int oldIndex, int newIndex) {
    setState(() {
      Widget row = _rows.removeAt(oldIndex);
      _rows.insert(newIndex, row);
    });
  }

  @override
  void initState() {
    _rows = List<Widget>.generate(
        10,
        (int index) => Text('This is row $index',
            key: ValueKey(index), textScaleFactor: 1.5));
    _ratingController.text = "3.0";
    eventId = widget.eventInfo.id;
    slotList = widget.eventInfo.slotList;
    userId = SessionManager.getUserId();
    ratingItemList.add(RatingItem(Key("0"), slotList[0], 0, this.rateFunc));
    ratingItemList.add(RatingItem(Key("1"), slotList[1], 1, this.rateFunc));
    ratingItemList.add(RatingItem(Key("2"), slotList[2], 2, this.rateFunc));
    ratingItemList.add(RatingItem(Key("3"), slotList[3], 3, this.rateFunc));
    super.initState();
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

  void _onReorder(int oldIndex, int newIndex) {
    int temp;
    temp = Ind[oldIndex];
    Ind[oldIndex] = Ind[newIndex];
    Ind[newIndex] = temp;
    setState(() {
      Widget _item = ratingItemList.removeAt(oldIndex);
      ratingItemList.insert(newIndex, _item);
    });
  }

  handleRate() async {
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
      await SlotBookManager.updateRate(widget.slotBookId, true);

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
    Widget reorderableColumn = ReorderableColumn(
      header: Text('List-like view but supports IntrinsicWidth'),
      children: _rows,
      onReorder: _onReorder,
      onNoReorder: (int index) {
        debugPrint(
            '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
      },
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            color: Colors.white,
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        centerTitle: true,
        title: Text(widget.eventInfo.name ?? 'Rating Users'),
      ),
      body: SingleChildScrollView(
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
            Transform(
              transform: Matrix4.rotationZ(0),
              alignment: FractionalOffset.topLeft,
              child: Material(
                child: Card(child: reorderableColumn),
                elevation: 6.0,
                color: Colors.transparent,
                borderRadius: BorderRadius.zero,
              ),
            ),
            CustomButton(
              text: 'Rate',
              onPressed: handleRate,
            ),
          ],
        ),
      ),
    );
  }

  void rateFunc(int index, double rMark) {
    setState(() {
      this._ratings[index] = rMark;
    });
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

class RatingItem extends StatefulWidget {
  final Key key;
  final Slot slotInfo;
  final int index;
  final Function onRateFunc;

  RatingItem(this.key, this.slotInfo, this.index, this.onRateFunc)
      : super(key: key);

  @override
  _RatingItemState createState() => _RatingItemState();
}

class _RatingItemState extends State<RatingItem> {
  var _registerStatus;
  String userId;
  double rating;

  RegisterStatus findRegisterStatus(slotInfo) {
    Slot _slotInfo = slotInfo;
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
      initialRating: rating,
      unratedColor: Colors.grey[200],
      itemSize: 30,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.orange,
      ),
      onRatingUpdate: (rating) {
        widget.onRateFunc(index, rating);
      },
    );
  }

  @override
  void initState() {
    userId = SessionManager.getUserId();
    _registerStatus = findRegisterStatus(widget.slotInfo);
    rating = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                      'Booker: ${_registerStatus == RegisterStatus.Empty ? 'Free' : widget.slotInfo.userName}',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: _registerStatus == RegisterStatus.Registered
                        ? _ratingBar(widget.index)
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
