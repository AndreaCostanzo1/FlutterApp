import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beertastic/blocs/map_bloc.dart';
import 'package:flutter_beertastic/model/city.dart';
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
  MapBloc _mapBloc;

  List<City> _cities;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height * 0.4),
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
                        child: StreamBuilder<List<City>>(
                          stream: _mapBloc.nearestCityStream,
                          builder: (context, snapshot) {
                            List<City> cities = snapshot.data??List();
                            City nearestCity = cities.length>0?cities.removeAt(0):null;
                            return PopupMenuButton(
                              onSelected: (city)=> _loadCity(city),
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.white,
                                size: 36,
                              ),
                              itemBuilder: (BuildContext context) {
                                return [
                                  nearestCity==null?PopupMenuItem(
                                    key: UniqueKey(),
                                    enabled: false,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('Close to refresh'),
                                        Icon(Icons.cloud_download,color: Colors.black,)
                                      ],
                                    ),
                                  ):
                                  PopupMenuItem(
                                    key: UniqueKey(),
                                    value: nearestCity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(nearestCity.name),
                                        Icon(Icons.near_me,color: Colors.black,)
                                      ],
                                    ),
                                  ),
                                  ...cities.map((city) => PopupMenuItem(
                                    key: UniqueKey(),
                                    value: city,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(city.name),
                                      ],
                                    ),
                                  )),
                                ];
                              },
                            );
                          }
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
          height: MediaQuery.of(context).size.height * 0.067,
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
                              minWidth: MediaQuery.of(context).size.width * 0.4,
                              child: FlatButton(
                                onPressed: () => print('tap'),
                                child: Text('Cancel'),
                              ),
                            )),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width * 0.4,
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
    _mapBloc = MapBloc();
    _cities=List();
    _mapBloc.retrieveNearestCities();
  }

  @override
  void dispose() {
    _mapBloc.dispose();
    super.dispose();
  }

  _loadCity(city) {
    
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
