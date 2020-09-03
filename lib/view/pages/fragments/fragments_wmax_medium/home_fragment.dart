import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_beertastic/blocs/event_bloc.dart';
import 'package:flutter_beertastic/model/event.dart';
import 'package:flutter_beertastic/blocs/articles_bloc.dart';
import 'package:flutter_beertastic/blocs/user_bloc.dart';
import 'package:flutter_beertastic/model/article.dart';
import 'package:flutter_beertastic/model/user.dart';
import 'package:flutter_beertastic/view/pages/event_page.dart';

import '../../article_page.dart';

class HomeFragment extends StatefulWidget {
  HomeFragment({Key key}) : super(key: key);

  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  UserBloc _userBloc;
  EventBloc _eventBloc;
  double _scrollSize;
  MyUser _user;
  bool _firstLoad;
  bool _loadingNewEvents;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MyUser>(
        stream: _userBloc.authenticatedUserStream,
        builder: (context, userSnap) {
          if (userSnap.data != null) {
            _user = userSnap.data;
            if (_firstLoad) {
              _eventBloc.retrieveEventsInCity(userSnap.data.city);
              _firstLoad = false;
            }
          }
          return StreamBuilder<List<Event>>(
              stream: _eventBloc.eventsStream,
              builder: (context, eventsSnap) {
                return eventsSnap.data == null
                    ? Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Container(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    : Stack(
                        children: <Widget>[
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            constraints: BoxConstraints.expand(
                                height: (165 + _scrollSize)),
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
                          ),
                          RefreshIndicator(
                            onRefresh: () => _handleRefresh(),
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (notification) =>
                                  _handleScroll(notification),
                              child: ListView(
                                physics: BouncingScrollPhysics(),
                                key: PageStorageKey('scrollingStar'),
                                padding: EdgeInsets.all(0),
                                //ListView has default top padding, to override it we insert padding = 0;
                                scrollDirection: Axis.vertical,
                                children: <Widget>[
                                  _TopPage(),
                                  SizedBox(height: 10),
                                  _TitleBar(
                                    'Next events in ' + userSnap.data.city.name,
                                    TextStyle(
                                        fontSize: 25,
                                        fontFamily: 'Montserrat Bold',
                                        color: Colors.black87),
                                  ),
                                  _Events(eventsSnap.data),
                                  _eventBloc.downloadedEvents == 0
                                      ? Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 30),
                                          child: Text(
                                            'No events available',
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : Container(),
                                  _eventBloc.noMoreEventsAvailable
                                      ? Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 30),
                                          child: Text(
                                            'No more events',
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : Container(),
                                  _loadingNewEvents
                                      ? Column(
                                          children: [
                                            Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10, vertical: 30),
                                                width: 30,
                                                height: 30,
                                                child:
                                                CircularProgressIndicator())
                                          ],
                                        )
                                      : Container(),
                                  SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
              });
        });
  }

  @override
  void initState() {
    super.initState();
    _userBloc = UserBloc();
    _userBloc.getAuthenticatedUserData();
    _eventBloc = EventBloc();
    _scrollSize = 0;
    _firstLoad = true;
    _loadingNewEvents = false;
  }

  @override
  void dispose() {
    _userBloc.dispose();
    _eventBloc.dispose();
    super.dispose();
  }

  _handleRefresh() async {
    if (_user != null) {
      await _eventBloc.retrieveEventsInCity(_user.city);
    }
    return null;
  }

  _handleScroll(ScrollNotification notification) {
    int pixels = notification.metrics.pixels.truncate();
    if (notification.metrics.axis == Axis.vertical) {
      _checkBoxHeightUpdate(pixels);
      if (!_eventBloc.noMoreEventsAvailable &&
          notification.metrics.pixels == notification.metrics.maxScrollExtent) {
        _loadOtherEvents();
      }
    }
  }

  void _checkBoxHeightUpdate(int pixels) async {
    double scrollSize = -1;
    if (pixels <= 0 && pixels >= -6 && pixels.toDouble() != _scrollSize)
      scrollSize = 0;
    else if (pixels <= -7 &&
        pixels >= -50 &&
        pixels.toDouble() != _scrollSize &&
        pixels % 4 == 0)
      scrollSize = -pixels.toDouble();
    else if (pixels <= -50 &&
        pixels >= -80 &&
        pixels.toDouble() != _scrollSize &&
        pixels % 5 == 0)
      scrollSize = -pixels.toDouble() + 10;
    else if (pixels <= -80 && pixels >= -85 && pixels.toDouble() != _scrollSize)
      scrollSize = -pixels.toDouble() + 20;
    else if (pixels <= -120 &&
        pixels >= -125 &&
        pixels.toDouble() != _scrollSize) scrollSize = -pixels.toDouble() + 30;
    if (scrollSize != -1)
      SchedulerBinding.instance
          .addPostFrameCallback((timeStamp) => setState(() {
                _scrollSize = scrollSize;
              }));
  }

  void _loadOtherEvents() async {
    setState(() => _loadingNewEvents = true);
    Future<List<Event>> newEvents = _eventBloc.eventsStream.first;
    _eventBloc.retrieveMoreEventsInCity(_user.city);
    await newEvents;
    setState(() => _loadingNewEvents = false);
  }
}

class _TopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
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
  ArticlesBloc _articlesBloc;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Article>>(
        stream: _articlesBloc.articlesController,
        builder: (context, snapshot) {
          List<Article> _articles = snapshot.data;
          return _articles == null ? Container() : _ArticlesRow(_articles);
        });
  }

  @override
  void initState() {
    super.initState();
    _articlesBloc = ArticlesBloc();
    _articlesBloc.retrieveArticles();
  }

  @override
  void dispose() {
    super.dispose();
    _articlesBloc.dispose();
  }
}

class _ArticlesRow extends StatefulWidget {
  final List<Article> _articles;

  _ArticlesRow(this._articles);

  @override
  __ArticlesRowState createState() => __ArticlesRowState();
}

class __ArticlesRowState extends State<_ArticlesRow> {
  final double _containerHeight = 200;

  final PageController pageController = PageController(viewportFraction: 0.86);

  int currentPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _containerHeight,
      margin: EdgeInsets.only(top: 8),
      child: PageView(
        key: PageStorageKey('paf'),
        controller: pageController,
        scrollDirection: Axis.horizontal,
        children: widget._articles.map((article) {
          bool activePage = widget._articles.indexOf(article) == currentPage;
          return AnimatedContainer(
            key: ValueKey(article.id),
            child: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Hero(
                      tag: article.id,
                      child: Image(
                        image: NetworkImage(article.coverImage),
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
                        builder: (context) => ArticlePage(
                            widget._articles.elementAt(currentPage)),
                      ),
                    ),
                    child: Container(
                      height: _containerHeight,
                      child: SingleChildScrollView(
                        //single child scroll view needed to render subtitle,
                        //but shouldn't be scrollable
                        physics: NeverScrollableScrollPhysics(),
                        //This disallow scroll with touch screen
                        child: Container(
                          height: activePage
                              ? _containerHeight * 0.9
                              : _containerHeight * 0.9 - 20,
                          padding: EdgeInsets.only(
                              top: _containerHeight * 0.115,
                              left: MediaQuery.of(context).size.width * 0.04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    height: _containerHeight * 0.6,
                                    width: MediaQuery.of(context).size.width *
                                        0.72,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          child: AutoSizeText(
                                            article.title,
                                            style: TextStyle(
                                                color: Color(0xF2F2F2F2),
                                                fontSize: 28,
                                                fontFamily:
                                                    'PlayfairDisplay Bold'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  activePage
                                      ? Container(
                                          height: 20,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.72,
                                          child: AutoSizeText(
                                            article.punchline,
                                            style: TextStyle(
                                                color: Color(0xF2F2F2F2),
                                                fontSize: 16,
                                                fontFamily:
                                                    'Montserrat Regular'),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            margin: EdgeInsets.only(
                top: activePage ? 0 : 20,
                right: MediaQuery.of(context).size.width * 0.0729,
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
  final List<Event> events;

  _Events(this.events);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: events.map((event) {
        return _EventBox(event, key: ValueKey(event.toJson().toString()));
      }).toList(),
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}

class _EventBox extends StatefulWidget {
  final Event _event;

  _EventBox(this._event, {Key key}) : super(key: key);

  @override
  __EventBoxState createState() => __EventBoxState();
}

class __EventBoxState extends State<_EventBox> {
  EventBloc _eventBloc;

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.87;
    double cardHeight = 240;
    double proportionImageTitle = 0.57;
    double dateContainerSize = 53;
    return Container(
      width: cardWidth,
      margin: EdgeInsets.symmetric(vertical: 10),
      height: cardHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          child: InkWell(
            onTap: () => _openEventPage(context, widget._event),
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: cardHeight * proportionImageTitle,
                      width: cardWidth,
                      child: StreamBuilder<Uint8List>(
                          stream: _eventBloc.eventImageStream,
                          builder: (context, snapshot) {
                            return snapshot.data == null
                                ? Ink(
                                    color: Colors.grey.withOpacity(0.6),
                                  )
                                : Ink.image(
                                    image: MemoryImage(snapshot.data),
                                    fit: BoxFit.cover,
                                  );
                          }),
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
                  day: widget._event.date.day.toString(),
                  monthAbbreviation:
                      _computeMonthAbbreviation(widget._event.date),
                ),
                _EventBody(
                  dateContainerSize,
                  cardWidth,
                  cardHeight,
                  title: widget._event.reducedTitle,
                  subTitle: _computePunchLineSubstring(widget._event.punchLine),
                  place: widget._event.placeName,
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
  }

  @override
  void initState() {
    super.initState();
    _eventBloc = EventBloc();
    _eventBloc.retrieveEventImage(widget._event);
  }

  _openEventPage(BuildContext context, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventPage(event),
      ),
    );
  }

  String _computePunchLineSubstring(String punchLine) {
    if (punchLine.length < 37) return punchLine;
    int indexToCut = punchLine.indexOf(' ', 30);
    return punchLine.substring(0, indexToCut) + '...';
  }

  String _computeMonthAbbreviation(DateTime dateTime) {
    Map<int, String> monthAbbreviations = Map.from({
      DateTime.january: 'JAN',
      DateTime.february: 'FEB',
      DateTime.march: 'MAR',
      DateTime.april: 'APR',
      DateTime.may: 'MAY',
      DateTime.june: 'JUN',
      DateTime.july: 'JUL',
      DateTime.august: 'AUG',
      DateTime.september: 'SEP',
      DateTime.october: 'OCT',
      DateTime.november: 'NOV',
      DateTime.december: 'DEC',
    });

    return monthAbbreviations[dateTime.month];
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

//FIXME CANCEL ME
List eventList = [
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
