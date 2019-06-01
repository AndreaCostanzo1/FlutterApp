import 'package:flutter/material.dart';

import 'package:flutter_beertastic/view/pages/beer_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        primarySwatch: Colors.amber,
        primaryColorDark: Colors.amber[600],
        accentColor: Colors.amber[400],
      ),
      home: BeerPage(title: 'Flutter Demo Home Page'),
    );
  }
}


