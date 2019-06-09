import 'package:flutter/material.dart';

class BeerPageThemeSmall {

  static final BeerPageThemeSmall _instance = BeerPageThemeSmall._createInstance();

  factory BeerPageThemeSmall(){
    return _instance;
  }

  BeerPageThemeSmall._createInstance();

  final Color canvasColor = Colors.amber[400];

  final TextTheme textTheme = const TextTheme(
    title: TextStyle(
      fontSize: 32.0,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    subtitle: TextStyle(
      color: Colors.black45,
      fontSize: 11,
      fontWeight: FontWeight.normal,
    ),
    display1: TextStyle(
      color: Color(0xffffca28),
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
    ),
    display2: TextStyle(
      color: Colors.white,
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
    ),
    overline: TextStyle(
      color: Colors.white70,
      fontSize: 12.0,
      letterSpacing: 0,
    ),
  );
}