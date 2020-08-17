import 'package:flutter/material.dart';
import 'package:flutter_beertastic/view/components/others/list_view_items.dart';
import 'package:flutter_beertastic/model/beer.dart';


final Beer beer = Beer.fromSnapshot(Map.from({'id': '8006890768305', 'name': 'Ichnsua', 'producer': 'Ichnusa', 'rating': 3.0, 'alcohol': 4.7, 'temperature': 5.0, 'imageUrl': 'beer_images/ichnusa.png', 'style': 'Lager', 'color': '3', 'carbonation': 2.5}));

class FavouritesPage extends StatelessWidget {
  FavouritesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          _TopPage(),
          SizedBox(height: 10,),
          BeerEntry(beer)
        ],
      ),
    );
  }

}

class _TopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.04),
              child: __TitleBar(
                  'Favourites',
                  TextStyle(
                      fontFamily: 'Campton Bold',
                      fontSize: 40,
                      color: Color(0xf2f2f2f2))),
            )
          ],
        ),
      ),
    );
  }
}

class __TitleBar extends StatelessWidget {
  final String title;
  final TextStyle textStyle;

  __TitleBar(this.title, this.textStyle);

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
