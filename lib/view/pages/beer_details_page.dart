import 'package:flare_flutter/flare_actor.dart';

import 'package:flutter/material.dart';
import 'package:flutter_beertastic/blocs/beer_bloc.dart';
import 'package:flutter_beertastic/blocs/likes_bloc.dart';
import 'package:flutter_beertastic/model/beer.dart';

import 'package:flutter_beertastic/view/components/icons/custom_icons.dart';

Color bottomBarColor = Colors.amber[300];
Color bottomBarSquareColor = Colors.amber[500];

class DetailsPage extends StatefulWidget {
  final Beer _beer;

  DetailsPage(this._beer, {Key key}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  BeerBloc _beerBloc;
  LikesBloc _likesBloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bottomBarColor,
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 32.0),
                Container(
                  width: 200.0,
                  child: Text(
                    'Product Overview',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 48.0),
                  ),
                ),
                SizedBox(height: 32.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 16.0),
                      itemRow(CustomIcons.beer, 'Style', widget._beer.style),
                      SizedBox(height: 16.0),
                      colorRow(widget._beer.color),
                      SizedBox(height: 16.0),
                      itemRow(Icons.bubble_chart, 'Carbonation',
                          widget._beer.carbonation.toString()),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.0),
          StreamBuilder<Beer>(
              stream: _beerBloc.singleBeerStream,
              builder: (context, snapshot) {
                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 48.0),
                      child: Container(
                        height: 60.0,
                        decoration: BoxDecoration(
                            color: bottomBarSquareColor,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32.0),
                                bottomLeft: Radius.circular(32.0))),
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 20.0),
                            Icon(Icons.search, color: Colors.white, size: 24.0),
                            SizedBox(width: 40.0),
                            Text(
                              snapshot.data == null
                                  ? widget._beer.searches.toString()
                                  : snapshot.data.searches.toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 48.0),
                      child: Container(
                        height: 60.0,
                        decoration: BoxDecoration(
                            color: bottomBarSquareColor,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32.0),
                                bottomLeft: Radius.circular(32.0))),
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 20.0),
                            Icon(Icons.favorite_border,
                                color: Colors.white, size: 24.0),
                            SizedBox(width: 40.0),
                            Text(
                              snapshot.data == null
                                  ? widget._beer.likes.toString()
                                  : snapshot.data.likes.toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
          Spacer(),
          StreamBuilder<bool>(
              stream: _likesBloc.likedBeerStream,
              builder: (context, snapshot) {
                return Container(
                  height: 80.0,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      snapshot.data == null
                          ? CustomBackgroundedIconButton(
                              topLeftRadius: Radius.circular(48),
                              backgroundColor: Colors.grey.withOpacity(0.7),
                            )
                          : snapshot.data
                              ? AnimatedContainer(
                                  height: 80,
                                  duration: Duration(milliseconds: 300),
                                  width: MediaQuery.of(context).size.width / 2,
                                  curve: Curves.ease,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(48),
                                          topRight: Radius.zero,
                                          bottomLeft: Radius.zero,
                                          bottomRight: Radius.zero)),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(48),
                                          topRight: Radius.zero,
                                          bottomLeft: Radius.zero,
                                          bottomRight: Radius.zero),
                                      onTap: () =>
                                          _updateLikeStatus(snapshot.data),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.favorite,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 6.0,
                                          ),
                                          Text(
                                            'remove',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : AnimatedContainer(
                                  height: 80,
                                  duration: Duration(milliseconds: 300),
                                  width: MediaQuery.of(context).size.width / 2,
                                  curve: Curves.ease,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(48),
                                          topRight: Radius.zero,
                                          bottomLeft: Radius.zero,
                                          bottomRight: Radius.zero)),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(48),
                                          topRight: Radius.zero,
                                          bottomLeft: Radius.zero,
                                          bottomRight: Radius.zero),
                                      onTap: () =>
                                          _updateLikeStatus(snapshot.data),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.favorite_border,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 6.0,
                                          ),
                                          Text(
                                            'add to favorites',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                    ],
                  ),
                );
              })
        ],
      ),
    );
  }

  _updateLikeStatus(bool liked) {
    _likesBloc.clearLikedBeerStream();
    if (liked) {
      _likesBloc.removeFromFavourites(widget._beer);
      _beerBloc.removeFromFavourites(widget._beer);
    } else {
      _likesBloc.addToFavourites(widget._beer);
      _beerBloc.addToFavourites(widget._beer);
    }
  }

  @override
  void initState() {
    super.initState();
    _beerBloc = BeerBloc();
    _likesBloc = LikesBloc();
    _likesBloc.verifyIfLiked(widget._beer.id);
    _beerBloc.observeSingleBeer(widget._beer.id);
  }

  @override
  void dispose() {
    super.dispose();
    _likesBloc.dispose();
    _beerBloc.dispose();
  }

  Widget itemRow(icon, name, title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              icon,
              color: Colors.black,
              size: 28,
            ),
            SizedBox(width: 6.0),
            Text(
              name,
              style: TextStyle(color: Colors.black, fontSize: 20.0),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Text(title, style: TextStyle(color: Colors.black, fontSize: 20.0)),
            SizedBox(
              width: 2,
            ),
          ],
        ),
      ],
    );
  }

  Widget colorRow(String color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.color_lens,
              color: Colors.black,
              size: 28,
            ),
            SizedBox(width: 6.0),
            Text(
              'Color',
              style: TextStyle(color: Colors.black, fontSize: 20.0),
            ),
          ],
        ),
        Container(
          width: 156,
          height: 40,
          child: FlareActor(
            "assets/animations/simple_color_bar.flr",
            animation: color,
          ),
        ),
      ],
    );
  }
}

class CustomBackgroundedIconButton extends StatelessWidget {
  final Radius topLeftRadius;
  final Radius topRightRadius;
  final Radius bottomLeftRadius;
  final Radius bottomRightRadius;
  final Color backgroundColor;
  final Color outlineColor;
  final double buttonHeight;

  CustomBackgroundedIconButton(
      {this.backgroundColor = const Color(0xff2c2731),
      this.outlineColor = Colors.white,
      this.topLeftRadius = Radius.zero,
      this.topRightRadius = Radius.zero,
      this.bottomLeftRadius = Radius.zero,
      this.bottomRightRadius = Radius.zero,
      this.buttonHeight = 80.0});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: buttonHeight,
      duration: Duration(milliseconds: 300),
      width: MediaQuery.of(context).size.width / 2,
      curve: Curves.ease,
      decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
              topLeft: topLeftRadius,
              topRight: topRightRadius,
              bottomLeft: bottomLeftRadius,
              bottomRight: bottomRightRadius)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.only(
              topLeft: topLeftRadius,
              topRight: topRightRadius,
              bottomLeft: bottomLeftRadius,
              bottomRight: bottomRightRadius),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.access_time,
                color: outlineColor,
              ),
              SizedBox(
                width: 6.0,
              ),
              Text(
                'loading...',
                style: TextStyle(color: outlineColor),
              )
            ],
          ),
        ),
      ),
    );
  }
}
