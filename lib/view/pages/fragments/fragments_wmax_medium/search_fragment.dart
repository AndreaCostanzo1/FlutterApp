import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beertastic/model/beer.dart';

import '../../beer_page.dart';


class SearchFragment extends StatefulWidget {
  @override
  _SearchFragmentState createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> {
  bool _focused;
  FocusNode _focusNode;
  TextEditingController _controller;

  void search(String text) {
    if (text == '')
      unfocusSearch();
    else {
      //TODO: perform search
    }
  }

  void unfocusSearch() {
    _focusNode.unfocus();
    setState(() {
      _focused = false;
    });
  }

  @override
  void initState() {
    _focused = _focused ?? false;
    _focusNode = FocusNode();
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        physics:
            _focused ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
        padding: EdgeInsets.all(0),
        children: <Widget>[
          AnimatedContainer(
            height: _focused ? 0 : 160,
            duration: Duration(milliseconds: 100),
          ),
          AnimatedContainer(
            width: MediaQuery.of(context).size.width,
            duration: Duration(milliseconds: 100),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _focused
                    ? BorderRadius.zero
                    : BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                      top: _focused ? 45 : 35, left: 30, right: 30, bottom: 10),
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: 270,
                          child: TextFormField(
                            controller: _controller,
                            focusNode: _focusNode,
                            onTap: () => setState(() => _focused = true),
                            onFieldSubmitted: (text) => search(text),
                            decoration: InputDecoration.collapsed(
                                hintText: 'Search',
                                hintStyle: TextStyle(
                                    fontFamily: 'Open Sans SemiBold')),
                          ),
                        ),
                        _focused
                            ? IconButton(
                                padding: EdgeInsets.all(0),
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _controller.clear();
                                  _focusNode.unfocus();
                                  setState(() => _focused=false);
                                },
                              )
                            : ScannerButton(),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: Color(0xFFf4f2e4),
                      borderRadius: BorderRadius.circular(30)),
                ),
                SizedBox(
                  height: 35,
                ),
                _focused
                    /*TODO: Create a class SearchResult and switch with this container
                    * add also the BLoC with the stream for the results
                    */
                    ? Container(
                        height: MediaQuery.of(context).size.height,
                      )
                    : PostGallery(),
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

class PostGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          PostSubGallery1(),
          SizedBox(
            height: 20,
          ),
          PostSubGallery2(),
          SizedBox(
            height: 20,
          ),
          PostSubGallery3(),
        ],
      ),
    );
  }
}

class PostSubGallery1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.width * 0.567,
            width: MediaQuery.of(context).size.width * 0.567,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(color: Colors.black),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.width * 0.567,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.width * 0.265,
                  width: MediaQuery.of(context).size.width * 0.265,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black),
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.width * 0.265,
                  width: MediaQuery.of(context).size.width * 0.265,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class PostSubGallery2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.width * 0.265,
            width: MediaQuery.of(context).size.width * 0.265,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(color: Colors.black),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.width * 0.265,
            width: MediaQuery.of(context).size.width * 0.265,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(color: Colors.black),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.width * 0.265,
            width: MediaQuery.of(context).size.width * 0.265,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostSubGallery3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.width * 0.567,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.width * 0.265,
                  width: MediaQuery.of(context).size.width * 0.265,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black),
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.width * 0.265,
                  width: MediaQuery.of(context).size.width * 0.265,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.width * 0.567,
            width: MediaQuery.of(context).size.width * 0.567,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(color: Colors.black),
              ),
            ),
          ),
        ],
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

class ScannerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.all(0),
      icon: Icon(Icons.center_focus_strong),
      onPressed: () => openScanner(context),
    );
  }

  void openScanner(BuildContext context) async {
    String result = await MethodChannel("CAMERA_X").invokeMethod('SCAN');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BeerPage(result),
      ),
    );
  }
}
