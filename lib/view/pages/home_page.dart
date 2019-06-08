import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                OutlineButton(onPressed: ()=> FirebaseAuth.instance.signOut(), child: Text('Sign out'),),
                OutlineButton(onPressed: ()=> _launchCameraX(context), child: Text('CameraX'),),
              ],
            ), //column
          ),
        ), //container
      ), //center
    );
  }

  void _launchCameraX(BuildContext context){

  }
}
