import 'package:flutter/material.dart';

class BeerPageThemeMedium {

  static final BeerPageThemeMedium _instance = BeerPageThemeMedium._createInstance();

  factory BeerPageThemeMedium(){
    return _instance;
  }

  BeerPageThemeMedium._createInstance();

  final Color canvasColor = Colors.amber[400];

  final TextTheme textTheme = const TextTheme(
    title: TextStyle(
      fontSize: 48.0,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    subtitle: TextStyle(
      color: Colors.black45,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    display1: TextStyle(
      color: Color(0xffffca28),
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
    ),
    display2: TextStyle(
      color: Colors.white,
      fontSize: 42.0,
      fontWeight: FontWeight.bold,
    ),
    overline: TextStyle(
      color: Colors.white70,
      fontSize: 18.0,
      letterSpacing: 0,
    ),
  );


}
