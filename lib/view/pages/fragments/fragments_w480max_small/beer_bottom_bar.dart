import 'package:flutter/material.dart';

const Color defaultCommentTextColor = Colors.white70;
const Color defaultBottomBarTextColor = Colors.white;
const Color defaultBottomBarSquareColor = Color(0xffffb300);

class BeerBottomBarSmall extends StatelessWidget {
  final Map beer;
  final Color bottomBarTextColor;
  final Color bottomBarSquareColor;
  final Color commentTextColor;

  BeerBottomBarSmall(
    this.beer, {
    this.commentTextColor = defaultCommentTextColor,
    this.bottomBarTextColor = defaultBottomBarTextColor,
    this.bottomBarSquareColor = defaultBottomBarSquareColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 12.0),
            Text('Information',
                style: TextStyle(
                  color: bottomBarTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                )),
            Spacer(),
            SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: 70.0,
                  width: MediaQuery.of(context).size.width / 2 - 50,
                  decoration: BoxDecoration(
                      color: bottomBarSquareColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32.0),
                          topRight: Radius.circular(32.0))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            beer['alcohol'],
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28.0),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            '\%',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12.0),
                          )
                        ],
                      ),
                      Text(
                        'alcohol',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 70.0,
                  width: MediaQuery.of(context).size.width / 2 - 50,
                  decoration: BoxDecoration(
                      color: bottomBarSquareColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32.0),
                          topRight: Radius.circular(32.0))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            beer['temperature'],
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28.0),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            '\°c',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12.0),
                          ),
                        ],
                      ),
                      Text(
                        'Temperature',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
