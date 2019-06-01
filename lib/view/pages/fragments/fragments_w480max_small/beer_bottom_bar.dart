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
            Text(
              'Information',
              style:
                  Theme.of(context).textTheme.display2.copyWith(fontSize: 12),
            ),
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
                            style: Theme.of(context).textTheme.display2,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            '\%',
                            style: Theme.of(context).textTheme.overline,
                          ),
                        ],
                      ),
                      Text(
                        'alcohol',
                        style: Theme.of(context).textTheme.overline,
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
                            style: Theme.of(context).textTheme.display2,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            '\°c',
                            style: Theme.of(context).textTheme.overline,
                          ),
                        ],
                      ),
                      Text(
                        'Temperature',
                        style: Theme.of(context).textTheme.overline,
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
