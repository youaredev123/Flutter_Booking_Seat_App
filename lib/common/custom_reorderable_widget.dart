import 'package:flutter/material.dart';

class CustomReorderableWidget extends StatefulWidget {
  @override
  _CustomReorderableWidgetState createState() =>
      _CustomReorderableWidgetState();
}

class _CustomReorderableWidgetState extends State<CustomReorderableWidget> {
  List<String> _list = ["Apple", "Ball", "Cat", "Dog", "Elephant"];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      child: ReorderableListView(
        padding: EdgeInsets.all(8),
        children: _list
            .map((item) => ListTile(
                  key: Key("${item}"),
                  title: Text("${item}"),
                  trailing: Icon(Icons.menu),
                ))
            .toList(),
        onReorder: (int start, int current) {
          print("start:  $start, current: $current");
          // dragging from top to bottom
          if (start < current) {
            int end = current - 1;
            String startItem = _list[start];
            int i = 0;
            int local = start;
            do {
              _list[local] = _list[++local];
              i++;
            } while (i < end - start);
            _list[end] = startItem;
          }
          // dragging from bottom to top
          else if (start > current) {
            String startItem = _list[start];
            for (int i = start; i > current; i--) {
              _list[i] = _list[i - 1];
            }
            _list[current] = startItem;
          }
          setState(() {});
        },
      ),
    );
  }
}
