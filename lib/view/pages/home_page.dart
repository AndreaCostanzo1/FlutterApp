import 'package:flutter/material.dart';

import 'package:flutter_beertastic/view/components/buttons/custom_raised_button.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/logo.png'),
                SizedBox(
                  height: 55,
                ),
                CustomRaisedButton(
                  'Sign up',
                  () => {}, //fixme
                  Colors.amber[200],
                  minWidth: 300.0,
                ),
                SizedBox(
                  height: 25,
                ),
                CustomRaisedButton(
                  'Sign in',
                  () => {},
                  Color(0xffbab6ac),
                  minWidth: 300.0,
                )
              ],
            ), //column
          ),
        ), //container
      ), //center
    );
  }
}
