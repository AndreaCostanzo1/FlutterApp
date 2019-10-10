import 'package:flutter/cupertino.dart';
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
      backgroundColor: Color(0xfffffbf0),
      body: Container(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            _TopPage(),
            SizedBox(height: 8),
            _TitleBar(
              'This week in Milan',
              TextStyle(
                  fontSize: 25,
                  fontFamily: 'Montserrat Bold',
                  color: Colors.black87),
            ),
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

class _BlogArticles extends StatefulWidget {
  @override
  _BlogArticlesState createState() => _BlogArticlesState();
}

class _BlogArticlesState extends State<_BlogArticles> {
  PageController pageController = PageController(viewportFraction: 0.86);

  double containerHeight = 200;

  int currentPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: containerHeight,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: PageView(
        controller: pageController,
        scrollDirection: Axis.horizontal,
        children: data.map((article) {
          bool activePage = data.indexOf(article) == currentPage;
          return AnimatedContainer(
            child: SingleChildScrollView(
              child: Container(
                padding:
                    EdgeInsets.only(top: containerHeight * 0.615, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(),
                      child: Text(
                        'My title is big',
                        style: TextStyle(
                            color: Color(0xF2F2F2F2),
                            fontSize: 28,
                            fontFamily: 'PlayfairDisplay Bold'),
                      ),
                    ),
                    activePage
                        ? Container(
                            child: Text(
                              'Lorem ipsum dolor sic amet',
                              style: TextStyle(
                                  color: Color(0xF2F2F2F2),
                                  fontSize: 16,
                                  fontFamily: 'Montserrat Regular'),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
            margin: EdgeInsets.only(
                top: activePage ? 0 : 20,
                right: 30,
                bottom: activePage ? 10 : 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
                image: NetworkImage(article['image']),
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

class _TitleBar extends StatelessWidget {
  final String title;
  final TextStyle textStyle;

  _TitleBar(this.title, this.textStyle);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: textStyle,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(15),
          constraints: BoxConstraints.expand(height: 165),
          decoration: BoxDecoration(
              gradient: new LinearGradient(
                  colors: [
                    Theme.of(context).primaryColorLight,
                    Theme.of(context).primaryColorDark
                  ],
                  begin: const FractionalOffset(1.0, 1.0),
                  end: const FractionalOffset(0.2, 0.2),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _TitleBar(
                    'Discover',
                    TextStyle(
                        fontFamily: 'Montserrat Bold',
                        fontSize: 28,
                        color: Color(0xf2f2f2f2)))
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 80),
          child: _BlogArticles(),
        ),
      ],
    );
  }
}

class _Events extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.87;
    double cardHeight = 240;
    double proportionImageTitle = 0.57;
    double dateContainerSize = 53;
    return Column(
      children: data.map((brewery) {
        return Container(
          width: cardWidth,
          margin: EdgeInsets.symmetric(vertical: 10),
          height: cardHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: cardHeight * proportionImageTitle,
                      width: cardWidth,
                      child: Image(
                        image: NetworkImage(brewery['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: cardHeight * (1 - proportionImageTitle),
                      width: cardWidth,
                      color: Colors.white,
                    ),
                  ],
                ),
                _DateBox(
                  dateContainerSize,
                  cardWidth,
                  cardHeight,
                  day: '11',
                  monthAbbreviation: 'JEN',
                ),
                _EventBody(
                  dateContainerSize,
                  cardWidth,
                  cardHeight,
                  title: 'Compleanno birrificio',
                  subTitle: 'Questa piccola descrizione breve',
                  place: 'Birrificio di Lambrate',
                )
              ],
            ),
          ),
          //clipRRect
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xBB000000),
                blurRadius: 10,
                offset: Offset(5, 5),
              ),
            ],
          ),
        );
      }).toList(),
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}

class _DateBox extends StatelessWidget {
  final double dateContainerSize;
  final double cardWidth;
  final double cardHeight;
  final String day;
  final String monthAbbreviation;

  _DateBox(this.dateContainerSize, this.cardWidth, this.cardHeight,
      {this.day, this.monthAbbreviation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dateContainerSize,
      height: dateContainerSize,
      margin: EdgeInsets.fromLTRB(cardWidth * 0.061, cardHeight * 0.43, 0, 0),
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Colors.white,
            ),
          ),
          Container(
            height: dateContainerSize * 0.95,
            width: dateContainerSize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  day,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 24,
                      fontFamily: 'Open Sans SemiBold'),
                ),
                Text(
                  monthAbbreviation,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 10.5,
                      fontFamily: 'Open Sans Bold'),
                ),
              ],
            ),
          )
        ],
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 7,
          ),
        ],
      ),
    );
  }
}

class _EventBody extends StatelessWidget {
  final double dateContainerSize;
  final double cardWidth;
  final double cardHeight;
  final String title;
  final String subTitle;
  final String place;

  _EventBody(this.dateContainerSize, this.cardWidth, this.cardHeight,
      {this.title, this.subTitle, this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: cardHeight * 0.675,
          left: cardWidth * 0.04,
          right: cardWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontFamily: 'Montserrat Bold', fontSize: 21),
          ),
          Container(
            //small padding to make sub-event element look nicer
            padding: EdgeInsets.symmetric(horizontal: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  subTitle,
                  style: TextStyle(
                    fontFamily: 'Montserrat Regular',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.place,
                      color: Colors.black54,
                      size: 17,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      place,
                      style: TextStyle(
                        fontFamily: 'Montserrat Regular',
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
