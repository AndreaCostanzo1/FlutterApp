import 'package:flutter/material.dart';

import 'package:flutter_beertastic/view/components/text_fields/fancy_text_field.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {

  TextEditingController emailTextFieldController = new TextEditingController();
  FocusNode emailFocus= new FocusNode();
  TextEditingController passwordTextFieldController = new TextEditingController();
  FocusNode passwordFocus= new FocusNode();
  TextEditingController confirmPasswordTextFieldController = new TextEditingController();
  FocusNode confirmPasswordFocus= new FocusNode();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      overflow: Overflow.visible,
      children: <Widget>[
        Card(
          elevation: 2.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            width: 300.0,
            child: Column(
              children: <Widget>[
                FancyTextField(
                  emailTextFieldController,
                  emailFocus,
                  label: 'Email address',
                  icon: Icons.mail_outline,
                ),
                Container(
                  width: 250.0,
                  height: 1.0,
                  color: Colors.grey[400],
                ),
                FancyTextField(
                  passwordTextFieldController,
                  passwordFocus,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  suffixIcon: Icons.remove_red_eye,
                ),
                Container(
                  width: 250.0,
                  height: 1.0,
                  color: Colors.grey[400],
                ),
                FancyTextField(
                  passwordTextFieldController,
                  passwordFocus,
                  label: 'Confirm password',
                  icon: Icons.lock_outline,
                  suffixIcon: Icons.remove_red_eye,
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 250.0),
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: ThemeColors.loginGradientStart,
                offset: Offset(1.0, 6.0),
                blurRadius: 20.0,
              ),
              BoxShadow(
                color: ThemeColors.loginGradientEnd,
                offset: Offset(1.0, 6.0),
                blurRadius: 20.0,
              ),
            ],
            gradient: new LinearGradient(
                colors: [
                  ThemeColors.loginGradientEnd,
                  ThemeColors.loginGradientStart
                ],
                begin: const FractionalOffset(0.2, 0.2),
                end: const FractionalOffset(1.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: MaterialButton(
            highlightColor: Colors.transparent,
            splashColor: ThemeColors.loginGradientEnd,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 10.0, horizontal: 42.0),
              child: Text(
                "SIGN UP",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontFamily: "WorkSansBold"),
              ),
            ),
            onPressed: () => {},
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    emailTextFieldController.dispose();
    emailFocus.dispose();
    passwordTextFieldController.dispose();
    passwordFocus.dispose();
    confirmPasswordTextFieldController.dispose();
    confirmPasswordFocus.dispose();
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