import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {
  final double height;
  final double minWidth;
  final String text;
  final Function listener;
  final Color color;

  CustomRaisedButton(
    this.text,
    this.listener,
    this.color, {
    this.height = 48.0,
    this.minWidth = 150,
  });

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      height: height,
      minWidth: minWidth,
      buttonColor: color,
      child: RaisedButton(
        onPressed: () => listener(),
        elevation: 8.0,
        textColor: Colors.black,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 17.0,
          ),
        ),
      ), //RaisedButton
    ); //buttonTheme
  }
}
