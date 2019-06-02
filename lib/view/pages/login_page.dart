import 'package:flutter/material.dart';

import 'package:flutter_beertastic/view/components/buttons/custom_raised_button.dart';
import 'package:flutter_beertastic/view/components/buttons/custom_outline_button.dart';
import 'package:flutter_beertastic/view/components/text_fields/email_field.dart';
import 'package:flutter_beertastic/view/components/text_fields/password_field.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/logo.png'),
                SizedBox(
                  height: 25,
                ),
                EmailField(),
                PasswordField(),
                SizedBox(
                  height: 25,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CustomRaisedButton(
                      'Log in',
                      () => {}, //fixme
                      Colors.amber[200],
                    ),
                    SizedBox(
                      width: 25,
                    ),
                    CustomOutlineButton(
                      'Forgot password?',
                      () => {}, //fixme
                      Colors.amber[200],
                    )
                  ],
                ),
              ],
            ), //column
          ),
        ), //container
      ), //center
    );
  }
}
