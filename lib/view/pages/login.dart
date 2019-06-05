import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_beertastic/view/components/others/custom_labeled_switch.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_wmax_medium/login_form.dart';
import 'package:flutter_beertastic/view/pages/fragments/fragments_wmax_medium/register_form.dart';

class AuthenticationPage extends StatefulWidget {
  AuthenticationPage({Key key}) : super(key: key);

  @override
  _AuthenticationPageState createState() => new _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        },
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                  colors: [
                    ThemeColors.loginGradientStart,
                    ThemeColors.loginGradientEnd
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 1.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 75.0),
                  child: new Image(
                      width: 250.0,
                      height: 191.0,
                      fit: BoxFit.fill,
                      image: NetworkImage(
                          'http://www.stickpng.com/assets/images/585e639ecb11b227491c33ff.png')),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: CustomLabeledSwitch(_pageController,left,right),
                ),
                Expanded(
                  flex: 2,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => changePage(i),
                    children: <Widget>[
                      new ConstrainedBox(
                        constraints: const BoxConstraints.expand(),
                        child: _buildSignIn(context),
                      ),
                      new ConstrainedBox(
                        constraints: const BoxConstraints.expand(),
                        child: _buildSignUp(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pageController = PageController();
  }

  void changePage(int i){
    if (i == 0) {
      setState(() {
        right = Colors.white;
        left = Colors.black;
      });
    } else if (i == 1) {
      setState(() {
        right = Colors.black;
        left = Colors.white;
      });
    }
  }



  Widget _buildSignIn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          LoginForm(),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: FlatButton(
                onPressed: () {},
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

class ThemeColors {
  const ThemeColors();

  static const Color loginGradientStart = const Color(0xFFFFFF8D);
  static const Color loginGradientEnd = const Color(0xFFFF6F00);

  static const primaryGradient = const LinearGradient(
    colors: const [loginGradientStart, loginGradientEnd],
    stops: const [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}


