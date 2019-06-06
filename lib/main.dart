import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_beertastic/view/pages/authentication_page.dart';
import 'package:flutter_beertastic/view/pages/home_page.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
  debugPaintSizeEnabled = false;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        return Provider<FirebaseUser>.value(
          value:snapshot.data,
          child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
                brightness: Brightness.light,
                primarySwatch: Colors.amber,
                backgroundColor: Colors.white,
                primaryColorDark: Colors.amber[600],
                primaryColor: Colors.amber[400],
                textTheme: TextTheme(
                  title: TextStyle(color: Colors.black),
                  subtitle: TextStyle(color: Colors.black45),
                  display1: TextStyle(color: Colors.amber[400]),
                  display2: TextStyle(color: Colors.white),
                  overline: TextStyle(color: Colors.white70),
                )),
            home: snapshot.data==null? AuthenticationPage():HomePage(),
          ),
        );
      }
    );
  }
}
