import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_beertastic/view/components/others/custom_labeled_switch.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_wmax_medium/login_form.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_wmax_medium/register_form.dart';

import 'package:flutter_beertastic/blocs/authenticator.dart';
import 'package:flutter_beertastic/view/pages/reset_page.dart';

import 'package:provider/provider.dart';

class AuthenticationPage extends StatelessWidget {
  AuthenticationPage({Key key}) : super(key: key);

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
  int _page;
  Color right = Colors.white;
  Color left = Colors.black;
  FocusNode _changePageFocus;
  PageController _pageController;
  AuthenticatorInterface _authBLoC;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overScroll) {
        overScroll.disallowGlow();
      },
      child: Column(
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
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: CustomLabeledSwitch(_pageController, left, right),
          ),
          Expanded(
            flex: 2,
            child: Provider<AuthenticatorInterface>.value(
              value: _authBLoC,
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => changePage(i, context),
                children: <Widget>[
                  new ConstrainedBox(
                    constraints: const BoxConstraints.expand(),
                    child: SignInScreen(_page),
                  ),
                  new ConstrainedBox(
                    constraints: const BoxConstraints.expand(),
                    child: _buildSignUp(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changePage(int i, context) {
    _page = i;
    if (i == 0) {
      setState(() {
        right = Theme.of(context).cardColor;
        left = Theme.of(context).textTheme.headline6.color;
      });
    } else if (i == 1) {
      setState(() {
        right = Theme.of(context).textTheme.headline6.color;
        left = Theme.of(context).cardColor;
      });
    }
    FocusScope.of(context).requestFocus(_changePageFocus);
    _authBLoC.resetState();
  }

  @override
  void initState() {
    super.initState();
    _authBLoC =Authenticator();
    _changePageFocus = FocusNode();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController?.dispose();
    _changePageFocus.dispose();
    _authBLoC.dispose();
  }

  Widget _buildSignUp(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          SignUpForm(),
        ],
      ),
    );
  }
}

class SignInScreen extends StatelessWidget {
  final int _page;

  SignInScreen(this._page);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          LoginForm(),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: FlatButton(
                onPressed: () =>Navigator.push(context,  MaterialPageRoute(
                  builder: (context) => ResetPage()),
                ),
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: 16.0,
                      fontFamily: "WorkSansMedium"),
                )),
          ),
        ],
      ),
    );
  }
}
