import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beertastic/view/pages/event_page.dart';

import '../../article_page.dart';

class HomeFragment extends StatelessWidget {
  HomeFragment({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: PageStorageKey('scrollingStar'),
      padding: EdgeInsets.all(0),
      //ListView has default top padding, to override it we insert padding = 0;
      scrollDirection: Axis.vertical,
      children: <Widget>[
        _TopPage(),
        SizedBox(height: 10),
        _TitleBar(
          'This week in Milan',
          TextStyle(
              fontSize: 25,
              fontFamily: 'Montserrat Bold',
              color: Colors.black87),
        ),
        _Events(),
        SizedBox(height: 24),
      ],
    );
  }
}

class _TopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
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
            padding: EdgeInsets.only(left: 10, top: 15, right: 15, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 11),
                  child: _TitleBar(
                      'Discover',
                      TextStyle(
                          fontFamily: 'Montserrat Bold',
                          fontSize: 28,
                          color: Color(0xf2f2f2f2))),
                )
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 90),
          child: _BlogArticles(),
        ),
      ],
    );
  }
}

class _BlogArticles extends StatefulWidget {
  _BlogArticles();

  @override
  _BlogArticlesState createState() => _BlogArticlesState();
}

class _BlogArticlesState extends State<_BlogArticles> {
  final PageController pageController = PageController(viewportFraction: 0.86);

  final double containerHeight = 200;

  int currentPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: containerHeight,
      margin: EdgeInsets.only(top: 8),
      child: PageView(
        key: PageStorageKey('paf'),
        controller: pageController,
        scrollDirection: Axis.horizontal,
        children: data.map((article) {
          bool activePage = data.indexOf(article) == currentPage;
          return AnimatedContainer(
            child: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Hero(
                      tag: article['name'], //TODO animate transition
                      child: Image(
                        image: NetworkImage(article['image']),
                        colorBlendMode: BlendMode.darken,
                        color: Colors.black38,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticlePage(data[currentPage]),
                      ),
                    ),
                    child: SingleChildScrollView(
                      //single child scroll view needed to render subtitle,
                      //but shouldn't be scrollable
                      physics: NeverScrollableScrollPhysics(),
                      //This disallow scroll with touch screen
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(
                            top: containerHeight * 0.615, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(),
                              child: Text(
                                'My title is big and long',
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
                  ),
                ),
              ],
            ),
            margin: EdgeInsets.only(
                top: activePage ? 0 : 20,
                right: 30,
                bottom: activePage ? 10 : 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
    pageController.addListener(_changePage);
    //NOTE: pageController can be accessed before build
    //this is the only solution found to set current page to a dynamic value
    Future.delayed(Duration.zero, () {
      setState(() => currentPage = pageController.page.round());
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  _changePage() {
    int currentPosition = pageController.page.round();
    if (currentPage != currentPosition) {
      setState(() => currentPage = currentPosition);
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
            child: Material(
              child: InkWell(
                onTap: () => _openEventPage(context),
                child: Stack(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: cardHeight * proportionImageTitle,
                          width: cardWidth,
                          child: Ink.image(
                            image: NetworkImage(brewery['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          height: cardHeight * (1 - proportionImageTitle),
                          width: cardWidth,
                          color: Colors.transparent,
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

  _openEventPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventPage(),
      ),
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
      margin: EdgeInsets.fromLTRB(cardWidth * 0.061, cardHeight * 0.43, 0, 0),
      child: Ink(
        width: dateContainerSize,
        height: dateContainerSize,
        child: Stack(
          children: <Widget>[
            Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
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
