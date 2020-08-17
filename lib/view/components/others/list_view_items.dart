
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beertastic/blocs/beer_bloc.dart';
import 'package:flutter_beertastic/model/beer.dart';
import 'package:flutter_beertastic/view/pages/beer_page.dart';

class BeerEntry extends StatelessWidget {
  final Beer _beer;

  BeerEntry(this._beer);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {

          double containerWidth = constraints.maxWidth;
          double containerHeight = containerWidth*0.292;
          print(containerHeight/containerWidth);
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BeerPage(_beer.id)));
              },
              child: Container(
                padding: EdgeInsets.only(left: containerWidth * 0.05),
                height: containerHeight,
                width: containerWidth,
                child: Row(
                  children: [
                    StreamBuilder<Uint8List>(
                        stream: BeerBloc.getBeerImage(_beer.beerImageUrl),
                        builder: (context, snapshot) {
                          return Container(
                            width: containerWidth * 0.23,
                            height: containerWidth * 0.23,
                            child: snapshot.data != null
                                ? Ink(
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding:
                                EdgeInsets.all(containerHeight * 0.8 * 0.1),
                                child: Image.memory(
                                  snapshot.data,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                                : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                          );
                        }),
                    Container(
                      height: containerHeight * 0.8,
                      margin: EdgeInsets.only(left: containerWidth*0.03),
                      child: Column(
                        children: [
                          Container(
                            width: containerWidth * 0.64,
                            height: containerHeight * 0.45,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    AutoSizeText(
                                      _beer.name,
                                      style: TextStyle(fontFamily: "Campton Bold"),
                                      maxFontSize: 30,
                                      minFontSize: 25,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: containerWidth * 0.64,
                            height: containerHeight * 0.3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      _beer.producer,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}