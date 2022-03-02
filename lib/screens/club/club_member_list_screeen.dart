import 'package:eventbooking/screens/club/invite_list_widget.dart';
import 'package:eventbooking/screens/club/member_list_widget.dart';
import 'package:eventbooking/styles/mainStyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ClubMemberListScreen extends StatefulWidget {
  final int selIndex;
  final String clubId;
  ClubMemberListScreen(this.clubId, this.selIndex);

  @override
  _ClubMemberListScreenState createState() => _ClubMemberListScreenState();
}

class _ClubMemberListScreenState extends State<ClubMemberListScreen> {
  int _selIndex;

  @override
  void initState() {
    super.initState();
    _selIndex = widget.selIndex;
  }

  final Map<int, Widget> options = const <int, Widget>{
    0: Text('Members'),
    1: Text('Invites')
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        initialIndex: _selIndex,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("update club", style: appBarTitleStyle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }),
            backgroundColor: Colors.orange,
            bottom: TabBar(
              tabs: [
                Tab(
                  text: 'Members',
                ),
                Tab(text: 'Invites'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              MemberListWidget(widget.clubId),
              InviteListWidget(widget.clubId)
            ],
          ),
        ),
      ),
    );
  }
}
