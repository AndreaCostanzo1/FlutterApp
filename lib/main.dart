import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_beertastic/view/pages/beer_page.dart';

void main() {
  runApp(MyApp());
  debugPaintSizeEnabled=false;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: BeerPage(title: 'Flutter Demo Home Page'),
    );
  }
}
