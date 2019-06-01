import 'package:flutter/material.dart';

class EmailField extends StatelessWidget{

  final String _label = 'Email';
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: _label,
          prefixIcon: Icon(Icons.email),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.elliptical(20, 20)),
            gapPadding: 10.0,
          ),
        ),
      ),//text field
    ); //container
  }
}