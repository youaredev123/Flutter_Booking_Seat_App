import 'package:eventbooking/firebase_services/ClubManager.dart';
import 'package:eventbooking/firebase_services/ClubToUserManager.dart';
import 'package:eventbooking/models/index.dart';
import 'package:eventbooking/screens/club/ClubDetailScreen.dart';
import 'package:eventbooking/styles/mainStyle.dart';
import 'package:eventbooking/utils/Global.dart';
import 'package:eventbooking/utils/SessionManager.dart';
import 'package:flutter/material.dart';

class ClubListScreen extends StatefulWidget {
  @override
  _ClubListScreenState createState() => _ClubListScreenState();
}

class _ClubListScreenState extends State<ClubListScreen> {
  List<Club> _clubList = [];
  List<ClubToUser> _CTUList = [];
  String _currentUserId;
  Role _role;

  @override
  void initState() {
    super.initState();
    _currentUserId = SessionManager.getUserId();
    _role = SessionManager.getRole();
    this.getClubList();
  }

  getClubList() async {
    Global.showLoading();

    _CTUList = await ClubToUserManager.getMyClubListByUserId(_currentUserId);
    String _clubId = '';
    List<Club> clubList = [];

    for (int i = 0; i < _CTUList.length; i++) {
      _clubId = _CTUList[i].clubId;
      clubList.add(await ClubManager.getClubInfoById(_clubId));
    }
    setState(() {
      _clubList = clubList;
    });

    Global.dismissLoading();
  }

  addClub(newClub) {
    setState(() {
      _clubList.add(newClub);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('ClubList', style: appBarTitleStyle),
        elevation: 0.0,
        centerTitle: true,
        actions: <Widget>[
          Visibility(
            visible: _role != Role.USER,
            child: IconButton(
              icon: Icon(Icons.add),
              color: Colors.white,
              onPressed: () async {
                var res =
                    await Navigator.pushNamed(context, '/club/createClub');
                if (res == null) return;
                if (res is Club) {
                  addClub(res);
                }
              },
            ),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(8.0),
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: _clubList.length,
          itemBuilder: (context, index) {
            return clubItem(context: context, clubInfo: _clubList[index]);
          },
        ),
      ),
    );
  }

  Widget clubItem({BuildContext context, Club clubInfo}) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4))),
      color: Colors.grey[400],
      child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ClubDetailScreen(
                      clubInfo: clubInfo,
                    )));
          },
          child: ListTile(
            leading: clubInfo.imageUrl == ''
                ? Image.asset(
                    'assets/images/clubMark.png',
                    width: 100,
                    height: 100,
                  )
                : Image.network(
                    clubInfo.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.fill,
                  ),
            title: Text(clubInfo.name),
            subtitle: Text(clubInfo.address1),
            trailing: Icon(clubInfo.type == ClubType.PUBLIC
                ? Icons.public
                : Icons.security),
          )),
    );
  }
}
