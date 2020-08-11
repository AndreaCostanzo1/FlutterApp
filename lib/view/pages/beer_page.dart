import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:flutter_beertastic/model/beer.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_w320max_small/beer_bottom_bar.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_w320max_small/beer_main_fragment.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_wmax_medium/beer_bottom_bar.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_wmax_medium/beer_main_fragment.dart';
import 'package:flutter_beertastic/view/pages/styles/w320max_small/beer_page_style.dart';
import 'package:flutter_beertastic/view/pages/styles/wmax_medium/beer_page_style.dart';
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
                    value: Beer.fromSnapshot(snapshot.data.data),
                    //extract the page depending on dimension
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
        backgroundColor: BeerPageThemeSmall().canvasColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BeerMainFragmentSmall(
              beer,
            ),
            BeerBottomBarSmall(),
          ],
        ),
      ),
      //theme of the page
      data: Theme.of(context).copyWith(
        canvasColor: BeerPageThemeSmall().canvasColor,
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
        backgroundColor: BeerPageThemeMedium().canvasColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BeerMainFragmentMedium(),
            BeerBottomBarMedium(),
          ],
        ),
      ),
      //Theme of the page
      data: Theme.of(context).copyWith(
          canvasColor: BeerPageThemeMedium().canvasColor,
          textTheme: BeerPageThemeMedium().textTheme),
    );
  }
}
