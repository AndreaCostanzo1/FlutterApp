import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BeerReviewsPage extends StatelessWidget {
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
            _Ratings(),
            _RateBox(),
          ],
        ),
      ),
    );
  }
}

class _Ratings extends StatefulWidget {
  @override
  __RatingsState createState() => __RatingsState();
}

class __RatingsState extends State<_Ratings> {
  Map<String, bool> selectedRateMap;

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
        return ListView(
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.03,
                              top: MediaQuery.of(context).size.height * 0.013),
                          child: Text(
                            'Ratings',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: "Nunito Bold",
                            ),
                          ),
                        ),
                        _RatingSummary('5', constraints, selectedRateMap['5'],
                            _selectRate),
                        _RatingSummary('4', constraints, selectedRateMap['4'],
                            _selectRate),
                        _RatingSummary('3', constraints, selectedRateMap['3'],
                            _selectRate),
                        _RatingSummary('2', constraints, selectedRateMap['2'],
                            _selectRate),
                        _RatingSummary('1', constraints, selectedRateMap['1'],
                            _selectRate),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.06,
                        )
                      ],
                    );
                  },
                )),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
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
                          _UserRow(),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: constraints.maxWidth * 0.01),
                            margin: EdgeInsets.only(
                                bottom: constraints.maxWidth * 0.01),
                            child: Text(
                              'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s date color year',
                              style: TextStyle(fontFamily: "Open Sans Regular"),
                              textAlign: TextAlign.justify,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    selectedRateMap =
        Map.from({'5': false, '4': false, '3': false, '2': false, '1': false});
  }

  _selectRate(String vote) {
    if (selectedRateMap[vote] != null) {
      if (selectedRateMap[vote]) {
        //case vote is selected, unselect and query all
        setState(() => selectedRateMap[vote] = false);
        //TODO implement query to db
      } else {
        //case vote is not selected: select it and unselect others, then query
        setState(() {
          selectedRateMap[vote] = true;
          selectedRateMap.forEach((key, value) {
            if (key != vote) selectedRateMap[key] = false;
          });
        });
        //TODO implement query to db
      }
    } else {
      print('Something went wrong: bad vote inserted');
    }
  }
}

class _RatingSummary extends StatelessWidget {
  final BoxConstraints _constraints;
  final String vote;
  final bool _selected;
  final Function _selectRate;

  _RatingSummary(
      this.vote, this._constraints, this._selected, this._selectRate);

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
                    __StarsWidget(vote),
                    SizedBox(
                      width: _constraints.maxWidth * 0.03,
                    ),
                    __ProgressBar(20, _constraints.maxWidth * 0.64),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 1.7),
                  child: Text(
                    '100' + '%',
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
  final double _level;
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

class _UserRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            ClipOval(
              child: Container(
                color: Colors.grey,
                width: width * 0.13,
                height: width * 0.13,
              ),
            ),
            SizedBox(
              width: width * 0.02,
            ),
            Column(
              children: <Widget>[
                Container(
                  child: Text(
                    'Nickname',
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
                '5',
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
}

class _RateBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return ScrollConfiguration(
      behavior: new ScrollBehavior()
        ..buildViewportChrome(context, null, AxisDirection.down),
      child: Column(
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
                          allowHalfRating: true,
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
                            decoration:
                                InputDecoration(border: InputBorder.none),
                            keyboardType: TextInputType.text,
                            minLines: 1,
                            //Normal textInputField will be displayed
                            maxLines: 6, //
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: constraints.maxWidth * 0.026),
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
      ),
    );
  }
}
