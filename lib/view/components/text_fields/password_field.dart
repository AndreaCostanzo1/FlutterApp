import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget{

  final String _label = 'Password';
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          labelText: _label,
          prefixIcon: Icon(Icons.lock),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.elliptical(20, 20)),
            gapPadding: 10.0,
          ),
        ),
      ),//text_field
    );//container;
  }
}