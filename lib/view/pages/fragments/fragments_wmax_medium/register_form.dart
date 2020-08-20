import 'package:flutter/material.dart';

import 'package:flutter_beertastic/view/components/text_fields/fancy_text_field.dart';

import 'package:flutter_beertastic/blocs/authenticator.dart';

import 'package:provider/provider.dart';

class SignUpForm extends StatefulWidget {
  final String registerEmailStateKey = 'registerEmail';
  final String registerPasswordStateKey = 'registerPassword';
  final String registerConfirmStateKey = 'registerConfirm';

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  TextEditingController _emailTextFieldController = new TextEditingController();
  FocusNode _emailFocus = new FocusNode();
  TextEditingController _passwordTextFieldController =
      new TextEditingController();
  FocusNode _passwordFocus = new FocusNode();
  TextEditingController _confirmPasswordTextFieldController =
      new TextEditingController();
  FocusNode _confirmPasswordFocus = new FocusNode();
  FocusNode _snackFocus;

  AuthenticatorInterface _authBLoC;

  @override
  Widget build(BuildContext context) {
    _authBLoC=Provider.of<AuthenticatorInterface>(context);
    return StreamBuilder(
      stream: _authBLoC.remoteError,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _showError(context, snapshot.data));
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_)=> Scaffold.of(context).removeCurrentSnackBar(reason: SnackBarClosedReason.dismiss));
        }
        return Stack(
          alignment: Alignment.topCenter,
          overflow: Overflow.visible,
          children: <Widget>[
            Card(
              elevation: 2.0,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Container(
                width: 300.0,
                child: Column(
                  children: <Widget>[
                    FancyTextField(
                      _emailTextFieldController,
                      _emailFocus,
                      label: 'Email address',
                      icon: Icons.mail_outline,
                      nextFocus: _passwordFocus,
                      insets: EdgeInsets.only(
                          top: 15.0, bottom: 15.0, left: 25.0, right: 25.0),
                      error: _computeEmailError(snapshot.data),
                    ),
                    Container(
                      width: 250.0,
                      height: 1.0,
                      color: Theme.of(context).dividerColor,
                    ),
                    FancyTextField(
                      _passwordTextFieldController,
                      _passwordFocus,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      suffixIcon: Icons.remove_red_eye,
                      nextFocus: _confirmPasswordFocus,
                      insets: EdgeInsets.only(
                          top: 15.0, bottom: 15.0, left: 25.0, right: 25.0),
                      error: _computePasswordError(snapshot.data),
                    ),
                    Container(
                      width: 250.0,
                      height: 1.0,
                      color: Theme.of(context).dividerColor,
                    ),
                    FancyTextField(
                      _confirmPasswordTextFieldController,
                      _confirmPasswordFocus,
                      label: 'Confirm password',
                      icon: Icons.lock_outline,
                      suffixIcon: Icons.remove_red_eye,
                      insets: EdgeInsets.only(
                          top: 15.0, bottom: 15.0, left: 25.0, right: 25.0),
                      error: _computeConfirmError(snapshot.data),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 225.0),
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Theme.of(context).primaryColorLight,
                    offset: Offset(1.0, 6.0),
                    blurRadius: 20.0,
                  ),
                  BoxShadow(
                    color: Theme.of(context).primaryColorDark,
                    offset: Offset(1.0, 6.0),
                    blurRadius: 20.0,
                  ),
                ],
                gradient: new LinearGradient(
                    colors: [
                      Theme.of(context).primaryColorDark,
                      Theme.of(context).primaryColorLight,
                    ],
                    begin: const FractionalOffset(0.2, 0.2),
                    end: const FractionalOffset(1.0, 1.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
              child: MaterialButton(
                highlightColor: Colors.transparent,
                splashColor: Theme.of(context).primaryColorDark,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 42.0),
                  child: Text(
                    "SIGN UP",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.headline3.color,
                        fontSize: 25.0,
                        fontFamily: "WorkSansBold"),
                  ),
                ),
                onPressed: () => _authBLoC.signUpWithEmailAndPassword(
                    _emailTextFieldController.text,
                    _passwordTextFieldController.text,
                    _confirmPasswordTextFieldController.text),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => {if(_emailFocus.hasFocus) _authBLoC?.resetState()});
    _passwordFocus.addListener(() => {if(_passwordFocus.hasFocus)_authBLoC?.resetState()});
    _confirmPasswordFocus.addListener(() => {if(_confirmPasswordFocus.hasFocus)_authBLoC?.resetState()});
  }

  @override
  void dispose() {
    super.dispose();
    _emailTextFieldController.dispose();
    _emailFocus.dispose();
    _passwordTextFieldController.dispose();
    _passwordFocus.dispose();
    _confirmPasswordTextFieldController.dispose();
    _confirmPasswordFocus.dispose();
  }

  void _showError(BuildContext context, RemoteError remoteError) async {
    if (_snackFocus == null) _snackFocus = FocusNode();
    //if a snack bar hasn't been displayed yet, display it
    if (!_snackFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_snackFocus);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _computeText(remoteError),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).backgroundColor,
              fontSize: 16,
              fontFamily: "WorkSansSemiBold",
            ),
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    }
  }

  String _computeText(RemoteError error) {
    String text = _ErrorTextComputer().errorTexts[error];
    return text == null ? 'Error during registration' : text;
  }

  bool _computeEmailError(RemoteError data) {
    return data == RemoteError.EMAIL_FORMAT;
  }

  bool _computePasswordError(RemoteError data) {
    return data == RemoteError.PASSWORD_FORMAT;
  }

  bool _computeConfirmError(RemoteError data){
    return data == RemoteError.NOT_MATCHING_PASSWORDS;
  }
}

class _ErrorTextComputer {
  final Map<RemoteError, String> _errorTexts = {
    RemoteError.EMAIL_FORMAT: 'Insert a valid email please!',
    RemoteError.PASSWORD_FORMAT: 'Password must have at least 6 characters',
    RemoteError.NOT_MATCHING_PASSWORDS: 'Passwords should match!',
    RemoteError.USER_ALREADY_EXIST: 'Email already in use',
  };

  Map<RemoteError, String> get errorTexts => _errorTexts;
}
