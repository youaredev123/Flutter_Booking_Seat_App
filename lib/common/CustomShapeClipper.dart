import 'package:flutter/material.dart';

class CustomShapeClipper extends CustomClipper<Path>{ 
  @override
  //Creating the Curve for the Top Bar.

  Path getClip(Size size) {
    final Path path =Path();
    path.lineTo(0.0,size.height);
    var firstEndpoint = Offset(size.width*.5,size.height -30.0);
    var firstControlpoint =Offset(size.width*0.25,size.height -50.0);
    path.quadraticBezierTo(firstControlpoint.dx, firstControlpoint.dy, firstEndpoint.dx,firstEndpoint.dy);
    var secoundEndpoint = Offset(size.width,size.height -80.0);
    var secoundControlPoint =Offset(size.width*0.75,size.height - 10.0);
    path.quadraticBezierTo(secoundControlPoint.dx, secoundControlPoint.dy, secoundEndpoint.dx,secoundEndpoint.dy);

   path.lineTo(size.width,0.0);
   path.close();
   return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) =>true;

}