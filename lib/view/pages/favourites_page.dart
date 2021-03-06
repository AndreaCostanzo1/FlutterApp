import 'package:flutter/material.dart';
import 'package:flutter_beertastic/blocs/likes_bloc.dart';
import 'package:flutter_beertastic/view/components/others/list_view_items.dart';
import 'package:flutter_beertastic/model/beer.dart';

class FavouritesPage extends StatefulWidget {
  FavouritesPage({Key key}) : super(key: key);

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  LikesBloc _likesBloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          _TopPage(),
          SizedBox(
            height: 10,
          ),
          StreamBuilder<List<Beer>>(
              stream: _likesBloc.likedBeerListStream,
              builder: (context, snapshot) {
                return snapshot.data == null
                    ? Container(
                        height: 10,
                      )
                    : Column(
                        children: <Widget>[
                          ...snapshot.data.map((beer) => BeerEntry(beer,key: ValueKey(beer.toString()))).toList(),
                        ],
                      );
              })
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _likesBloc = LikesBloc();
    _likesBloc.retrieveLikedBeers();
  }

  @override
  void dispose() {
    super.dispose();
    _likesBloc.dispose();
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
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.04),
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
