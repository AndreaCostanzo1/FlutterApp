import 'package:flutter/material.dart';

import 'package:flutter_beertastic/model/beer.dart';

import 'package:provider/provider.dart';

const double defaultTextOverLineTextSize = 14;

class BeerBottomBarMedium extends StatelessWidget {
  final double squareTextOverLineSize;

  BeerBottomBarMedium({
    this.squareTextOverLineSize=  defaultTextOverLineTextSize,
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
                style: Theme.of(context).textTheme.headline3.copyWith(
                  fontSize: 16,
                ),
            ),
            Spacer(),
            SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: 100.0,
                  width: MediaQuery.of(context).size.width / 2 - 50,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
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
                            Provider.of<Beer>(context).alcohol.toString(),
                            style: Theme.of(context).textTheme.headline3,
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
                        style: Theme.of(context).textTheme.overline.copyWith(fontSize: squareTextOverLineSize),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 100.0,
                  width: MediaQuery.of(context).size.width / 2 - 50,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
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
                            Provider.of<Beer>(context).temperature.toString(),
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            '\°c',
                            style: Theme.of(context).textTheme.overline,
                          )
                        ],
                      ),
                      Text(
                        'Temperature',
                        style: Theme.of(context).textTheme.overline.copyWith(fontSize: squareTextOverLineSize),
                      )
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
