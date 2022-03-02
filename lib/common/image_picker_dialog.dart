import 'dart:io';

import 'package:eventbooking/common/custom_button.dart';
import 'package:eventbooking/utils/helper/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

abstract class ImagePickListener {
  onImagePicked(File image, String ext);
}

class ImagePickerDialog extends StatelessWidget {
  final BuildContext context;
  final ImagePickListener _listener;

  ImagePickerDialog(this.context, this._listener);

  show(){
    showDialog(
      context: context,
      builder: (context) => Container(
        child: this,
      )
    );
  }

  dismiss(){
    Navigator.pop(context);
  }
  handleImage(File file){
    String ext = getExtension(file);
    _listener.onImagePicked(file, ext);

  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Opacity(
        opacity: 1.0,
        child: Container(
          padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: (){
                        dismiss();
                      },
                    ),
                  ),
                  SizedBox(height: 20,),
                  CustomButton(
                    text: 'Select from Photo Gallery',
                    onPressed: () async {
                      dismiss();
                      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
                      handleImage(image);                    }
                  ),
                  // SizedBox(height: 15,),
                  CustomButton(
                    text: 'Take a Photo',
                    onPressed: () async {
                      dismiss();
                      var image = await ImagePicker.pickImage(source: ImageSource.camera);
                      handleImage(image);
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      
    );
  }
}