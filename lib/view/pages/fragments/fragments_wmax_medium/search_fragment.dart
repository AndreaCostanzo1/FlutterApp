import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beertastic/model/beer.dart';

import '../../beer_page.dart';

List data = [
  {
    'name': 'Antelope Canyon',
    'image':
        'https://images.unsplash.com/photo-1527498913931-c302284a62af?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=934&q=80',
    'description':
        'Over the years, Lover Antelope Canyon has become a favorite gathering pace for photographers tourists, and visitors from the world.',
    'date': 'Mar 20, 2019',
    'rating': '4.7',
    'cost': '\$40.00'
  },
  {
    'name': 'Genteng Lembang',
    'image':
        'https://images.unsplash.com/photo-1548560781-a7a07d9d33db?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=581&q=80',
    'description':
        'Over the years, Lover Antelope Canyon has become a favorite gathering pace for photographers tourists, and visitors from the world.',
    'date': 'Mar 24, 2019',
    'rating': '4,83',
    'cost': '\$50.00'
  },
  {
    'name': 'Kamchatka Peninsula',
    'image':
        'https://images.unsplash.com/photo-1542869781-a272dedbc93e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=983&q=80',
    'description':
        'Over the years, Lover Antelope Canyon has become a favorite gathering pace for photographers tourists, and visitors from the world.',
    'date': 'Apr 18, 2019',
    'rating': '4,7',
    'cost': '\$30.00'
  },
];

class SearchFragment extends StatefulWidget {
  @override
  _SearchFragmentState createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> {
  bool focused;
  FocusNode focusNode;

  void search(String text){
    if(text=='') unfocusSearch();
    else{
      //TODO: perform search
    }
  }

  void unfocusSearch() {
    focusNode.unfocus();
    setState(() {
      focused = false;
    });
  }

  @override
  void initState() {
    focused = focused ?? false;
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        physics:
            focused ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
        padding: EdgeInsets.all(0),
        children: <Widget>[
          AnimatedContainer(
            height: focused ? 0 : 160,
            duration: Duration(milliseconds: 100),
          ),
          AnimatedContainer(
            width: MediaQuery.of(context).size.width,
            duration: Duration(milliseconds: 100),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: focused
                    ? BorderRadius.zero
                    : BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                      top: focused ? 45 : 35, left: 30, right: 30, bottom: 10),
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: 270,
                          child: TextFormField(
                            focusNode: focusNode,
                            onTap: () => setState(() => focused = true),
                            onFieldSubmitted: (text) => search(text),
                            decoration: InputDecoration.collapsed(
                                hintText: 'Search',
                                hintStyle: TextStyle(
                                    fontFamily: 'Open Sans SemiBold')),
                          ),
                        ),
                        focused
                            ? Container()
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
                focused
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

class ScannerButton extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.all(0),
      icon: Icon(Icons.center_focus_strong),
      onPressed: () => openScanner(context),);
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
