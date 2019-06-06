import 'package:flutter/material.dart';

import 'package:flutter_beertastic/view/components/text_fields/fancy_text_field.dart';

import 'package:flutter_beertastic/blocs/authenticator.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailTextFieldController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final TextEditingController _passwordTextFieldController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  FocusNode _snackFocus;

  final Authenticator _authBLoC = Authenticator();

  bool logging;

  @override
  Widget build(BuildContext context) {
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
                height: 190.0,
                child: Column(
                  children: <Widget>[
                    FancyTextField(
                      _emailTextFieldController,
                      _emailFocus,
                      label: 'Email',
                      icon: Icons.mail_outline,
                      nextFocus: _passwordFocus,
                      error: _computeEmailError(snapshot.data),
                    ),
                    Container(
                      width: 250.0,
                      height: 1.0,
                      color: Colors.grey[400],
                    ),
                    FancyTextField(
                      _passwordTextFieldController,
                      _passwordFocus,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      suffixIcon: Icons.remove_red_eye,
                      error: _computePasswordError(snapshot.data), //fixme
                    )
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 170.0),
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
                      Theme.of(context).primaryColorLight
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
                    "LOGIN",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.display2.color,
                        fontSize: 25.0,
                        fontFamily: "WorkSansBold"),
                  ),
                ),
                onPressed: () => _tryLogin(),
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
    _emailFocus.addListener(()=>{});
    _authBLoC.resetError();
  }

  @override
  void dispose() {
    super.dispose();
    _disposeAndUnFocus();
    _emailTextFieldController.dispose();
    _passwordTextFieldController.dispose();
    _authBLoC.resetError();
    _authBLoC.dispose();
    _snackFocus?.dispose();
  }

  void _disposeAndUnFocus() {
    _emailFocus.unfocus();
    _emailFocus.dispose();
    _passwordFocus.unfocus();
    _passwordFocus.dispose();
  }

  void _tryLogin() {
    setState(() {});
    _authBLoC.logWithEmailAndPassword(
        _emailTextFieldController.text, _passwordTextFieldController.text);
  }

  bool _computeEmailError(RemoteError error) {
    return error == RemoteError.EMAIL_FORMAT ||
        error == RemoteError.USER_NOT_FOUND;
  }

  bool _computePasswordError(RemoteError error) {
    return error == RemoteError.PASSWORD_FORMAT;
  }

  void _showError(BuildContext context, RemoteError remoteError) async {
    if (_snackFocus == null) _snackFocus = FocusNode();
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
    return text == null ? '' : text;
  }

  void _resetError() {
    _authBLoC.resetError();
  }
}

class _ErrorTextComputer {
  final Map<RemoteError, String> _errorTexts = {
    RemoteError.EMAIL_FORMAT: 'Insert a valid email please!',
    RemoteError.USER_NOT_FOUND: 'User doesn\'t exist! Use sign up instead'
  };

  Map<RemoteError, String> get errorTexts => _errorTexts;
}
