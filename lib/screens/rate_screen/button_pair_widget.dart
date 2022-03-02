import 'dart:convert';

import 'package:eventbooking/utils/helper/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';

import 'PickerData.dart';

class ButtionPair extends StatefulWidget {
  final int index;

  final Function onConfirmed;
  final bool isAdmin;
  final List<String> autoRateArray;
  ButtionPair(this.index, this.onConfirmed, this.isAdmin, this.autoRateArray);

  @override
  _ButtionPairState createState() => _ButtionPairState();
}

class _ButtionPairState extends State<ButtionPair> {
  List<int> rateArray = [];

  @override
  void initState() {
    super.initState();
    rateArray = getListFromString(widget.autoRateArray[widget.index]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    rateArray = getListFromString(widget.autoRateArray[widget.index]);
  }

  @override
  Widget build(BuildContext context) {
    rateArray = getListFromString(widget.autoRateArray[widget.index]);
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Center(
        child: InkWell(
          onTap: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 60,
                width: 60,
                child: OutlineButton(
                  onPressed: () {
                    if (!widget.isAdmin) return;
                    showCustomPicker(context, widget.onConfirmed, widget.index,
                        widget.autoRateArray, rateArray);
                  },
                  child: Text(
                    rateArray[0].toString(),
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              SizedBox(
                height: 60,
                width: 60,
                child: OutlineButton(
                  onPressed: () {
                    if (!widget.isAdmin) return;
                    showCustomPicker(context, widget.onConfirmed, widget.index,
                        widget.autoRateArray, rateArray);
                  },
                  child: Text(
                    rateArray[1].toString(),
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

showCustomPicker(BuildContext context, Function onConfirm, int index,
    List<String> autoRateArray, List<int> rateArray) {
  new Picker(
      selecteds: [rateArray[0], rateArray[1]],
      adapter: PickerDataAdapter<String>(
          pickerdata: new JsonDecoder().convert(PickerData2), isArray: true),
      hideHeader: true,
      title: new Text("Please Select"),
      onConfirm: (Picker picker, List value) {
        onConfirm(value, index);
      }).showDialog(context);
}
