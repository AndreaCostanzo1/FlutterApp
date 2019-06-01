import 'package:flutter/material.dart';

class CustomOutlineButton extends StatelessWidget {
  final double height;
  final double minWidth;
  final String text;
  final Function listener;
  final Color color;

  CustomOutlineButton(
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
      child: OutlineButton(
        onPressed: () => listener(),
        textColor: color,
        borderSide: BorderSide(
          width: 0.0,
          color: Colors.transparent,
        ),
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
