import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_beertastic/blocs/authenticator.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_wmax_medium/reset_form.dart';

import 'package:provider/provider.dart';

class ResetPage extends StatelessWidget {
  ResetPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new NetworkImage("https://firebasestorage.googleapis.com/v0/b/flutter-beertastic.appspot.com/o/Background.jpg?alt=media&token=25ecda05-de61-4cfa-8eb1-e50277501e08"),
              fit: BoxFit.cover,
            ),
          ),
          child: new Stack(
            children: <Widget>[
              new BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: new Container(
                  decoration: new BoxDecoration(color: Colors.black.withOpacity(0.1)),
                ),
              ),
              _PageContainer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageContainer extends StatefulWidget {
  @override
  __PageContainerState createState() => __PageContainerState();
}

class __PageContainerState extends State<_PageContainer>
    with SingleTickerProviderStateMixin {
  Color right = Colors.white;
  Color left = Colors.black;
  AuthenticatorInterface _authBLoC;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 75.0),
          child: new Image(
            width: 200.0,
            height: 200.0,
            fit: BoxFit.contain,
            image: AssetImage('assets/images/logo.png'),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height*0.1,),
        Expanded(
          flex: 2,
          child: Provider<AuthenticatorInterface>.value(
            value: _authBLoC,
            child: new ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: ResetForm(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _authBLoC=Authenticator();
  }

  @override
  void dispose() {
    super.dispose();
    _authBLoC.dispose();
  }
}