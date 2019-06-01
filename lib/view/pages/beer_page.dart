import 'package:flutter/material.dart';

import 'package:flutter_beertastic/view/pages/fragments/fragments_w480max_small/beer_bottom_bar.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_w480max_small/beer_main_fragment.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_wmax_medium/beer_bottom_bar.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_wmax_medium/beer_main_fragment.dart';
import 'package:flutter_beertastic/view/pages/utils/size_computer.dart';


Map beer = {
  'name': 'Beck\'s',
  'producer': 'Beck\'s producer',
  'image':
      'http://www.stickpng.com/assets/images/585e639ecb11b227491c33ff.png',
  'rating': '4.5',
  'alcohol': '4.5',
  'temperature': '5',
};

class BeerPage extends StatefulWidget {
  BeerPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _BeerState createState() => _BeerState();
}

class _BeerState extends State<BeerPage> {

  final Map<String,StatelessWidget> widgetsByDimensions ={
    SizeComputer.small: _SmallPage(),
    SizeComputer.medium: _MediumPage(),
  };


  @override
  Widget build(BuildContext context) {
    return widgetsByDimensions[SizeComputer.computeSize(MediaQuery.of(context).size.width)];
  }
}

class _SmallPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).accentColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BeerMainFragmentSmall(
              beer,
            ),
            BeerBottomBarSmall(beer),
          ],
        ));
  }

}

class _MediumPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Theme.of(context).accentColor,
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
        ));
  }

}


