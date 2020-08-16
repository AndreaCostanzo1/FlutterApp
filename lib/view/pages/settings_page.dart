import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: _TopPage(),
      ),
    );
  }
}

class _TopPage extends StatefulWidget {
  @override
  __TopPageState createState() => __TopPageState();
}

class __TopPageState extends State<_TopPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height*0.4),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/milan.jpg'),
                  fit: BoxFit.cover),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
          child: Container(
            padding: EdgeInsets.only(left: 10, top: 15, right: 15, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _TitleBar(
                          'Milan',
                          TextStyle(
                              fontFamily: 'Campton Bold',
                              fontSize: 36,
                              color: Color(0xf2f2f2f2))),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        child: PopupMenuButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 36,
                          ),
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                  child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Milan'),
                                ],
                              )),
                            ];
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height*0.067,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    child: Text(
                      'Nickname',
                      style:
                          TextStyle(fontFamily: "Campton Bold", fontSize: 26),
                    ),
                  ),
                ],
              ),
              TextFormField(
                style:
                    TextStyle(fontSize: 22, fontFamily: "Montserrat Regular"),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: ButtonTheme(
                              minWidth: MediaQuery.of(context).size.width*0.4,
                              child: FlatButton(
                                onPressed: () => print('tap'),
                                child: Text('Cancel'),
                              ),
                            )),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width*0.4,
                            child: RaisedButton(
                              onPressed: () => print('tap'),
                              child: Text('Confirm'),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _temp();
  }

  void _temp() async {
    Geolocator().getCurrentPosition().then((value) {
      Geolocator()
          .placemarkFromCoordinates(value.latitude, value.longitude)
          .then((value) {
        print('Locality: ' + value[0].locality);
        print('Adm area: ' + value[0].administrativeArea);
      });
    });
  }
}

class _TitleBar extends StatelessWidget {
  final String title;
  final TextStyle textStyle;

  _TitleBar(this.title, this.textStyle);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: textStyle,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
