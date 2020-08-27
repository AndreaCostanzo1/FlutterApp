import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:flutter_beertastic/view/pages/authentication_page.dart';
import 'package:flutter_beertastic/view/pages/home_page.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      key:UniqueKey(),
      title: 'Flutter Beertastic',
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.amber,
          backgroundColor: Colors.white,
          cardColor: Colors.white,
          primaryColorDark: Color(0xFFFF6F00),
          primaryColor: Colors.amber[600],
          primaryColorLight: Color(0xFFFFFF8D),
          errorColor: Color(0xffb00020),
          dividerColor: Colors.grey[400],
          textTheme: TextTheme(
            headline6: TextStyle(color: Colors.black),
            subtitle2: TextStyle(color: Colors.black45),
            headline4: TextStyle(color: Colors.amber[400]),
            headline3: TextStyle(color: Colors.white),
            overline: TextStyle(color: Colors.white70),
          )),
      home: FutureBuilder(
          key: UniqueKey(),
          future: Firebase.initializeApp(),
          builder: (context, firebaseSnap) {
            if (firebaseSnap.connectionState == ConnectionState.done) {
              return StreamBuilder<User>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, userSnap) {
                    return Provider<User>.value(
                      value: userSnap.data,
                      child: userSnap.data == null
                          ? AuthenticationPage(key: UniqueKey(),)
                          : HomePage(key: UniqueKey(),),
                    );
                  });
            }
            return LoadingScreen();
          }),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Container(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
