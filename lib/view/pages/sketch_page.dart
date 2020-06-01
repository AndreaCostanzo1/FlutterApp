import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_beertastic/view/pages/beer_page.dart';

List data = [
  {
    'name': 'Antelope Canyon',
    'image':
    'https://images.unsplash.com/photo-1527498913931-c302284a62af?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=934&q=80',
    'description':
    'Over the years, Lover Antelope Canyon has become a favorite gathering pace for photographers tourists, and visitors from the world.',
    'date': 'Mar 20, 2019',
    'rating': '4.7',
    'cost': '\$40.00'
  },
  {
    'name': 'Genteng Lembang',
    'image':
    'https://images.unsplash.com/photo-1548560781-a7a07d9d33db?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=581&q=80',
    'description':
    'Over the years, Lover Antelope Canyon has become a favorite gathering pace for photographers tourists, and visitors from the world.',
    'date': 'Mar 24, 2019',
    'rating': '4,83',
    'cost': '\$50.00'
  },
  {
    'name': 'Kamchatka Peninsula',
    'image':
    'https://images.unsplash.com/photo-1542869781-a272dedbc93e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=983&q=80',
    'description':
    'Over the years, Lover Antelope Canyon has become a favorite gathering pace for photographers tourists, and visitors from the world.',
    'date': 'Apr 18, 2019',
    'rating': '4,7',
    'cost': '\$30.00'
  },
];


class SketchPage extends StatefulWidget{
  @override
  _SketchPageState createState() => _SketchPageState();
}

class _SketchPageState extends State<SketchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            _TopTitle(),
            _Events(),
            SizedBox(height: 24),
            _BottomBar(),
          ],
        ),
      ), //center
    );
  }
}

class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _Articles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = 140;
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: data.map((brewery) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: height,
            width: width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  height: height - 0.10 * height,
                  width: height - 0.20 * height,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16)),
                      image: DecorationImage(
                        image: NetworkImage(brewery['image']),
                        fit: BoxFit.cover,
                      )),
                ),
                Container(
                  height: height - 0.23 * height,
                  width: width - 0.40 * width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16)),
                      color: Theme.of(context).primaryColorLight),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ExploreTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8, left: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'Explore',
                style: TextStyle(
                    fontSize: 32, fontFamily: 'Moon-Bold', color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Events extends StatefulWidget {
  @override
  __EventsState createState() => __EventsState();
}

class __EventsState extends State<_Events> {
  PageController pageController = PageController(viewportFraction: 0.8);

  int currentPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: PageView(
        controller: pageController,
        scrollDirection: Axis.horizontal,
        children: data.map((brewery) {
          bool activePage = data.indexOf(brewery) == currentPage;
          return AnimatedContainer(
            margin: EdgeInsets.only(
                top: activePage ? 0 : 20,
                right: 30,
                bottom: activePage ? 10 : 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
                image: NetworkImage(brewery['image']),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black87,
                    blurRadius: activePage ? 5 : 0,
                    offset: Offset(activePage ? 5 : 0, activePage ? 5 : 0)),
              ],
            ),
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOutQuint,
          );
        }).toList(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    currentPage = 0;
    pageController.addListener(() => _changePage());
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  _changePage() {
    int currentPosition = pageController.page.round();
    if (currentPage != currentPosition) {
      setState(() {
        currentPage = currentPosition;
      });
    }
  }
}

class _TopTitle extends StatefulWidget {
  @override
  __TopTitleState createState() => __TopTitleState();
}

class __TopTitleState extends State<_TopTitle> {
  bool filtering;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, left: 16),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Tonight',
                    style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Moon',
                        color: Color(0xffa3a191)),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    'in',
                    style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Moon',
                        color: Color(0xffa3a191)),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Text(
                    'Milan',
                    style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Moon-Bold',
                        color: Color(0xff7a7869)),
                  )
                ],
              ),
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Stack(
                    children: <Widget>[
                      AnimatedContainer(
                        width: 45,
                        height: filtering ? 45 : 20,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInCubic,
                        decoration: BoxDecoration(
                            color: filtering
                                ? Theme.of(context).primaryColorDark
                                : Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(32))),
                      ),
                      IconButton(
                          onPressed: () => _toggleFilters(),
                          icon: Icon(
                            Icons.tune,
                            color: filtering ? Colors.white : Color(0xffa3a191),
                          )),
                    ],
                  )),
            ],
          ),
          Container(
            decoration: BoxDecoration(),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    filtering = false;
  }

  void _toggleFilters() {
    setState(() {
      filtering = !filtering;
    });
  }
}