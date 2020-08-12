import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_wmax_medium/home_fragment.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_wmax_medium/profile_fragment.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_wmax_medium/search_fragment.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavBarIndex;
  Map<int, Widget> _map = HashMap();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffffbf0),
      body: _map[_bottomNavBarIndex] != null
          ? _map[_bottomNavBarIndex]
          : Container(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (newIndex) => setState(() => _bottomNavBarIndex = newIndex),
        currentIndex: _bottomNavBarIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('profile'),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _bottomNavBarIndex = 0;
    _map[0] = HomeFragment();
    _map[1] = SearchFragment(key: UniqueKey(),);
    _map[2] = ProfileFragment();
  }
}
