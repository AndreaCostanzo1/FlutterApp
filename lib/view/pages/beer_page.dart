import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:flutter_beertastic/model/beer.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_w320max_small/beer_bottom_bar.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_w320max_small/beer_main_fragment.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_wmax_medium/beer_bottom_bar.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_wmax_medium/beer_main_fragment.dart';
import 'package:flutter_beertastic/view/pages/styles/w320max_small/beer_page_style_small.dart';
import 'package:flutter_beertastic/view/utils/size_computer.dart';

import 'package:provider/provider.dart';

Map beer = {
  'name': 'Beck\'s',
  'producer': 'Beck\'s producer',
  'image': 'http://www.stickpng.com/assets/images/585e639ecb11b227491c33ff.png',
  'rating': '4.5',
  'alcohol': '4.5',
  'temperature': '5',
};

class BeerPage extends StatefulWidget {
  BeerPage(this.beerID, {Key key, this.title}) : super(key: key);

  final String title;
  final String beerID;
  final Map<String, Widget> widgetsByDimensions = {
    SizeComputer.small: _SmallPage(),
    SizeComputer.medium: _MediumPage(),
  };

  @override
  _BeerState createState() => _BeerState();
}

class _BeerState extends State<BeerPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection('beers')
          .document(widget.beerID)
          .snapshots(),
      builder: (context, snapshot) {
        return snapshot.data == null
            ? _RefreshIndicatorPage()
            : snapshot.data.exists
                ? Provider<Beer>.value(
                    value: Beer.fromSnapshot(snapshot.data),
                    child: widget.widgetsByDimensions[SizeComputer.computeSize(
                        MediaQuery.of(context).size.width)],
                  )
                : NoBeerPage();
      },
    );
  }
}

class _RefreshIndicatorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RefreshProgressIndicator(),
      ),
    );
  }
}

class NoBeerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text('We don\'t have this beer!')],
        ),
      ),
    );
  }
}

class _SmallPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BeerMainFragmentSmall(
              beer,
            ),
            BeerBottomBarSmall(beer),
          ],
        ),
      ),
      //theme of the page
      data: Theme.of(context).copyWith(
        textTheme: BeerPageThemeSmall().textTheme,
      ),
    );
  }
}

class _MediumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BeerMainFragmentMedium(
              beer,
            ),
            BeerBottomBarMedium(
              beer,
            )
          ],
        ),
      ),
      //Theme of the page
      data: Theme.of(context).copyWith(
        textTheme: TextTheme(
          title: TextStyle(
            fontSize: 48.0,
            color: Theme.of(context).textTheme.title.color,
            fontWeight: FontWeight.bold,
          ),
          subtitle: TextStyle(
            color: Theme.of(context).textTheme.subtitle.color,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          display1: TextStyle(
            color: Theme.of(context).textTheme.display1.color,
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
          ),
          display2: TextStyle(
            color: Theme.of(context).textTheme.display2.color,
            fontSize: 42.0,
            fontWeight: FontWeight.bold,
          ),
          overline: Theme.of(context).textTheme.overline.copyWith(
                fontSize: 18.0,
                letterSpacing: 0,
              ),
        ),
      ),
    );
  }
}
