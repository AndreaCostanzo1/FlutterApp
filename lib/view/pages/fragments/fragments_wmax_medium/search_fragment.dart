import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beertastic/model/beer.dart';

import '../../beer_page.dart';

class SearchFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          Container(
            height: 160,
          ),
          Container(
            height: 560,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            child: Column(
              children: <Widget>[
                Container(
                  margin:
                      EdgeInsets.only(top: 35, left: 30, right: 30, bottom: 10),
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: 270,
                          child: TextFormField(
                            decoration: InputDecoration.collapsed(
                                hintText: 'Search', hintStyle: TextStyle(fontFamily: 'Open Sans SemiBold')),
                          ),
                        ),
                        Icon(Icons.build)
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: Color(0xFFf4f2e4),
                      borderRadius: BorderRadius.circular(30)),
                ),
              ],
            ),
          )
        ],
      ),
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
    );
  }
}

class CameraXButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      onPressed: () => _launchCameraX(context),
      child: Text('CameraX'),
    );
  }

  void _launchCameraX(BuildContext context) async {
    String result = await MethodChannel("CAMERA_X").invokeMethod('SCAN');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BeerPage(result),
      ),
    );
  }
}

class SearchField extends SearchDelegate<Beer> {
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return null;
  }
}
