// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables, must_be_immutable

import 'package:flutter/material.dart';

class ViewPhoto extends StatelessWidget {
  var img, imageUrl;
  ViewPhoto({Key? key, this.img, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (img == null && imageUrl == " ") {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator(
          color: Colors.blue,
        )),
        backgroundColor: Colors.black,
      );
    }
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.black,
          width: size.width,
          height: size.height,
          child: (imageUrl == " ")
              ? Image(image: AssetImage(img))
              : Image(image: NetworkImage(imageUrl)),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
