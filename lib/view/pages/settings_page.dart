import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beertastic/blocs/map_bloc.dart';
import 'package:flutter_beertastic/blocs/user_bloc.dart';
import 'package:flutter_beertastic/model/city.dart';
import 'package:flutter_beertastic/model/user.dart';
import 'package:permission_handler/permission_handler.dart';

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
  UserBloc _userBloc;
  City _city;
  bool _cityUpdated;
  String _nickname;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MyUser>(
        stream: _userBloc.authenticatedUserStream,
        builder: (context, snapshot) {
          _city = _city ?? (snapshot.data != null ? snapshot.data.city : null);
          _nickname = _nickname ??
              (snapshot.data != null ? snapshot.data.nickname : null);
          if (_city != null&&_cityUpdated) {
            _mapBloc.retrieveCityImage(_city);
            _cityUpdated=false;
          }
          return snapshot.data == null
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Container(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : Column(
                  children: <Widget>[
                    StreamBuilder<Uint8List>(
                        stream: _mapBloc.cityImageStream,
                        builder: (context, snapshot) {
                          return Container(
                            constraints: BoxConstraints.expand(
                                height:
                                    MediaQuery.of(context).size.height * 0.4),
                            decoration: snapshot.data != null
                                ? BoxDecoration(
                                    image: DecorationImage(
                                        image: MemoryImage(snapshot.data),
                                        fit: BoxFit.cover),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(30),
                                        bottomRight: Radius.circular(30)))
                                : BoxDecoration(
                                    color: Colors.grey.withOpacity(0.6),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(30),
                                        bottomRight: Radius.circular(30)),
                                  ),
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 10, top: 15, right: 15, bottom: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        _TitleBar(
                                            _city.name,
                                            TextStyle(
                                                fontFamily: 'Campton Bold',
                                                fontSize: 36,
                                                color: Color(0xf2f2f2f2))),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 10),
                                          child: StreamBuilder<List<City>>(
                                              stream:
                                                  _mapBloc.nearestCityStream,
                                              builder: (context, snapshot) {
                                                List<City> cities =
                                                    snapshot.data ?? List();
                                                City nearestCity =
                                                    cities.length > 0
                                                        ? cities.removeAt(0)
                                                        : null;
                                                return PopupMenuButton(
                                                  onSelected: (city) =>
                                                      _loadCity(city),
                                                  icon: Icon(
                                                    Icons.more_vert,
                                                    color: Colors.white,
                                                    size: 36,
                                                  ),
                                                  itemBuilder:
                                                      (BuildContext context) {
                                                    return [
                                                      nearestCity == null
                                                          ? PopupMenuItem(
                                                              key: UniqueKey(),
                                                              enabled: false,
                                                              child: FutureBuilder<bool>(
                                                                future: Permission.location.isGranted,
                                                                builder: (context, snapshot) {
                                                                  return Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: <
                                                                        Widget>[
                                                                      snapshot.data!=null&&!snapshot.data? Text(
                                                                          'Permissions required'): Text(
                                                                          'Close to refresh'),
                                                                      snapshot.data!=null&&!snapshot.data?Icon(
                                                                        Icons
                                                                            .close,
                                                                        color: Colors
                                                                            .black,
                                                                      ):Icon(
                                                                        Icons
                                                                            .cloud_download,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ],
                                                                  );
                                                                }
                                                              ),
                                                            )
                                                          : PopupMenuItem(
                                                              key: ValueKey(
                                                                  nearestCity
                                                                      .id),
                                                              value:
                                                                  nearestCity,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: <
                                                                    Widget>[
                                                                  Text(nearestCity
                                                                      .name),
                                                                  Icon(
                                                                    Icons
                                                                        .near_me,
                                                                    color: Colors
                                                                        .black,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                      ...cities.map((city) =>
                                                          PopupMenuItem(
                                                            key: ValueKey(
                                                                city.id),
                                                            value: city,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                Text(city.name),
                                                              ],
                                                            ),
                                                          )),
                                                    ];
                                                  },
                                                );
                                              }),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
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
                                  style: TextStyle(
                                      fontFamily: "Campton Bold", fontSize: 26),
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: snapshot.data.nickname,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(14),
                            ],
                            onChanged: (text) => setState(() {
                              _nickname = text;
                            }),
                            style: TextStyle(
                                fontSize: 22, fontFamily: "Montserrat Regular"),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: ButtonTheme(
                                          minWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          child: FlatButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text('Cancel'),
                                          ),
                                        )),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: ButtonTheme(
                                        minWidth:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        child: _city == null
                                            ? RaisedButton(
                                                onPressed: () {},
                                                child: Text('Confirm'),
                                                color: Colors.grey,
                                              )
                                            : RaisedButton(
                                                onPressed: () async {
                                                  await _userBloc
                                                      .setInformation(
                                                          _nickname, _city);
                                                  Navigator.of(context).pop();
                                                },
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
        });
  }

  @override
  void initState() {
    super.initState();
    _mapBloc = MapBloc();
    _userBloc = UserBloc();
    _userBloc.getAuthenticatedUserData();
    _mapBloc.retrieveNearestCities();
    _cityUpdated=true;
  }

  @override
  void dispose() {
    _mapBloc.dispose();
    _userBloc.dispose();
    super.dispose();
  }

  _loadCity(city) {
    setState(() {
      if (city.id != _city.id) {
        _city = city;
        _cityUpdated=true;
      }
    });
    _mapBloc.retrieveNearestCities();
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
