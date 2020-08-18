import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beertastic/blocs/beer_bloc.dart';
import 'package:flutter_beertastic/blocs/profile_image_bloc.dart';
import 'package:flutter_beertastic/blocs/rating_bloc.dart';
import 'package:flutter_beertastic/model/beer.dart';
import 'package:flutter_beertastic/model/review.dart';
import 'package:flutter_beertastic/model/user.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BeerReviewsPage extends StatelessWidget {
  final Beer _beer;

  BeerReviewsPage(this._beer);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: new LinearGradient(
              colors: [
                Theme.of(context).primaryColorLight,
                Theme.of(context).primaryColorDark
              ],
              begin: const FractionalOffset(1.0, 1.0),
              end: const FractionalOffset(0.1, 0.1),
              stops: [0.5, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: Stack(
          children: <Widget>[
            _Ratings(_beer),
            _RateBox(),
          ],
        ),
      ),
    );
  }
}

class _Ratings extends StatefulWidget {
  final Beer _beer;

  _Ratings(this._beer);

  @override
  __RatingsState createState() => __RatingsState();
}

class __RatingsState extends State<_Ratings> {
  Map<int, bool> _selectedRateMap;

  ReviewsBloc _reviewBloc;
  BeerBloc _beerBloc;
  bool _loadNewData;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(
        left: screenWidth * 0.03,
        right: screenWidth * 0.03,
        top: screenHeight * 0.03,
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) => _handleScrollNotification(
              scrollInfo, MediaQuery.of(context).size.height),
          child: RefreshIndicator(
            onRefresh: () => _handleRefresh(),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return StreamBuilder<Beer>(
                                  stream: _beerBloc.singleBeerStream,
                                  builder: (context, snapshot) {
                                    Map<int, int> ratiosMap =
                                        _generateRatiosMap(snapshot);
                                    return Wrap(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.03,
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.013),
                                          child: Text(
                                            'Ratings',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontFamily: "Nunito Bold",
                                            ),
                                          ),
                                        ),
                                        ..._selectedRateMap.keys.map((rate) =>
                                            _RatingSummary(
                                                rate,
                                                constraints,
                                                _selectedRateMap[rate],
                                                _selectRate,
                                                ratiosMap[rate])),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.06,
                                        )
                                      ],
                                    );
                                  });
                            },
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      StreamBuilder<List<Review>>(
                          stream: _reviewBloc.reviewsStream,
                          builder: (context, snapshot) {
                            return snapshot.data != null
                                ? Column(
                                    children: <Widget>[
                                      _CommentBoxes(snapshot.data)
                                    ],
                                  )
                                : Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                          child: CircularProgressIndicator()),
                                    ],
                                  );
                          }),
                      _loadNewData
                          ? Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                Container(child: CircularProgressIndicator()),
                              ],
                            )
                          : Container(),
                      StreamBuilder<bool>(
                        stream: _reviewBloc.availableDocumentsStream,
                        builder: (context, snapshot) {
                          print('executed');
                          return snapshot.data == null || snapshot.data
                              ? Container(
                                  height: 1,
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text('No more reviews'),
                                );
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.18,
                      ),
                    ],
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _beerBloc = BeerBloc();
    _reviewBloc = ReviewsBloc();
    _loadNewData = false;
    _beerBloc.observeSingleBeer(widget._beer.id);
    _reviewBloc.retrieveAllReviews(widget._beer.id);
    _selectedRateMap =
        Map.from({5: false, 4: false, 3: false, 2: false, 1: false});
  }

  @override
  void dispose() {
    super.dispose();
    _reviewBloc.dispose();
    _beerBloc.dispose();
  }

  _selectRate(int vote) {
    if (_selectedRateMap[vote] != null) {
      _reviewBloc.clearStream();
      if (_selectedRateMap[vote]) {
        //case vote is selected, unselect and query all
        setState(() => _selectedRateMap[vote] = false);
        _reviewBloc.retrieveAllReviews(widget._beer.id);
      } else {
        //case vote is not selected: select it and unselect others, then query
        setState(() {
          _selectedRateMap[vote] = true;
          _selectedRateMap.forEach((key, value) {
            if (key != vote) _selectedRateMap[key] = false;
          });
        });
        _reviewBloc.retrieveReviewsWithVote(widget._beer.id, vote);
      }
    } else {
      print('Something went wrong: bad vote inserted');
    }
  }

  _handleScrollNotification(ScrollNotification scrollInfo, double height) {
    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
        scrollInfo.metrics.maxScrollExtent > height * 0.2) {
      //iterate to see if there's a true. If positive call retrieveWithRate
      setState(() {
        _loadNewData = true;
      });
      _awaitToCancelProgressIndicator();
      _controlIfDocumentsAreAvailable();
      _selectedRateMap.forEach((rate, selected) {
        if (selected)
          _reviewBloc.retrieveMoreReviewsWithRate(rate, widget._beer.id);
      });
      //if true is not present in the map, retrieve without considering ratings
      if (!_selectedRateMap.containsValue(true))
        _reviewBloc.retrieveMoreReviews(widget._beer.id);
    }
  }

  void _awaitToCancelProgressIndicator() async {
    await _reviewBloc.reviewsStream.first;
    setState(() {
      _loadNewData = false;
    });
  }

  Map<int, int> _generateRatiosMap(AsyncSnapshot<Beer> snapshot) {
    Map<int, int> map = _selectedRateMap.map((key, value) => MapEntry(key, 0));
    if (snapshot.data != null && snapshot.data.totalRatings > 0) {
      map = _selectedRateMap.map((key, value) => MapEntry(
          key,
          (snapshot.data.ratingsByRate[key] / snapshot.data.totalRatings * 100)
              .round()));
      int totalRatio = 0;
      map.values.forEach((ratio) => totalRatio += ratio);
      if (totalRatio < 100) {
        List<int> ratios = map.values.toList();
        ratios.sort();
        int keyToUpdate = map.entries
            .where((element) => element.value == ratios.last)
            .toList()
            .first
            .key;
        map.update(keyToUpdate, (value) => ratios.last + (100 - totalRatio));
      }
    }
    return map;
  }

  _handleRefresh() async {
    _selectedRateMap.forEach((key, value) => _selectedRateMap[key] = false);
    _reviewBloc.retrieveAllReviews(widget._beer.id);
    await _reviewBloc.reviewsStream.first;
    return null;
  }

  void _controlIfDocumentsAreAvailable() async {}
}

class _CommentBoxes extends StatelessWidget {
  final List<Review> _data;

  _CommentBoxes(this._data);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ..._data.map((review) => Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Wrap(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              left: constraints.maxWidth * 0.03,
                              right: constraints.maxWidth * 0.06,
                              top: constraints.maxWidth * 0.02,
                              bottom: constraints.maxWidth * 0.02),
                          child: Column(
                            children: <Widget>[
                              _UserRow(review.user, review.rate),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    left: constraints.maxWidth * 0.01),
                                margin: EdgeInsets.only(
                                    bottom: constraints.maxWidth * 0.01),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      review.comment,
                                      style: TextStyle(
                                          fontFamily: "Open Sans Regular",
                                          fontSize: 15),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            )),
      ],
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final BoxConstraints _constraints;
  final int vote;
  final bool _selected;
  final Function _selectRate;
  final int _rateRatio;

  _RatingSummary(this.vote, this._constraints, this._selected, this._selectRate,
      this._rateRatio);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: _constraints.maxWidth * 0.03,
          right: _constraints.maxWidth * 0.03,
          top: _constraints.maxWidth * 0.01,
          bottom: _constraints.maxWidth * 0.01),
      child: Material(
        color: _selected ? Colors.black.withOpacity(0.1) : Colors.transparent,
        child: InkWell(
          onTap: () => _selectRate(vote),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    __StarsWidget(vote.toString()),
                    SizedBox(
                      width: _constraints.maxWidth * 0.03,
                    ),
                    __ProgressBar(_rateRatio, _constraints.maxWidth * 0.64),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 1.7),
                  child: Text(
                    _rateRatio.toString() + '%',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Nunito Bold",
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class __StarsWidget extends StatelessWidget {
  final String vote;

  __StarsWidget(this.vote);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      Container(
        margin: EdgeInsets.only(top: 1.5),
        child: Text(
          vote,
          style: TextStyle(
              fontSize: 20, fontFamily: "Nunito Bold", color: Colors.amber),
        ),
      ),
      Icon(
        Icons.star,
        color: Colors.amber,
      )
    ]);
  }
}

class __ProgressBar extends StatelessWidget {
  final int _level;
  final double _width;
  final double _height = 18;

  __ProgressBar(this._level, this._width);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            Ink(
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5)),
              height: _height,
              width: _width,
            )
          ],
        ),
        Row(
          children: [
            Ink(
              decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(5),
                      right: Radius.circular(
                          _level > 90 ? 5 * (_level - 90) / 10 : 0))),
              height: _height,
              width: _width * _level / 100,
            )
          ],
        ),
      ],
    );
  }
}

class _UserRow extends StatefulWidget {
  final int _rate;

  final User _user;

  _UserRow(this._user, this._rate);

  @override
  __UserRowState createState() => __UserRowState();
}

class __UserRowState extends State<_UserRow> {
  ProfileImageBloc _imageBloc = ProfileImageBloc();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            StreamBuilder<ImageProvider>(
                stream: _imageBloc.userImageStream,
                builder: (context, snapshot) {
                  return ClipOval(
                    child: snapshot.data == null
                        ? Container(
                            color: Colors.grey,
                            width: width * 0.13,
                            height: width * 0.13,
                          )
                        : Container(
                            child: Image(image: snapshot.data),
                            width: width * 0.13,
                            height: width * 0.13,
                          ),
                  );
                }),
            SizedBox(
              width: width * 0.02,
            ),
            Column(
              children: <Widget>[
                Container(
                  child: Text(
                    widget._user.nickname,
                    style: TextStyle(fontSize: 22, fontFamily: "Nunito Bold"),
                  ),
                )
              ],
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 1.5),
              child: Text(
                widget._rate.toString(),
                style: TextStyle(
                    fontSize: 22,
                    fontFamily: "Nunito Bold",
                    color: Colors.amber),
              ),
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
            )
          ],
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _imageBloc = ProfileImageBloc();
    _imageBloc.getUserImage(widget._user.profileImagePath);
  }

  @override
  void dispose() {
    super.dispose();
    _imageBloc.dispose();
  }
}

class _RateBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          padding: EdgeInsets.only(
              left: screenWidth * 0.025,
              right: screenWidth * 0.025,
              top: screenHeight * 0.015,
              bottom: screenHeight * 0.015),
          child: LayoutBuilder(builder: (context, constraints) {
            return Column(
              children: <Widget>[
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          "Rate:",
                          style: TextStyle(
                              fontFamily: "Campton Bold", fontSize: 25),
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth * 0.05,
                      ),
                      RatingBar(
                        initialRating: 3,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2.5),
                  width: constraints.maxWidth,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: constraints.maxWidth * 0.8,
                        padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth * 0.02),
                        decoration: BoxDecoration(
                            color: Color(0xFFf4f2e4),
                            borderRadius: BorderRadius.circular(10)),
                        child: TextFormField(
                          decoration: InputDecoration(border: InputBorder.none),
                          keyboardType: TextInputType.text,
                          minLines: 1,
                          //Normal textInputField will be displayed
                          maxLines: 6, //
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.only(left: constraints.maxWidth * 0.026),
                        width: constraints.maxWidth * 0.2,
                        height: 47,
                        child: Material(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.amber,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => print('tap'),
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          }),
        ),
      ],
    );
  }
}
