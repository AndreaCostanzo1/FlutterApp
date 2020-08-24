import 'package:flutter/material.dart';

import 'package:flutter_beertastic/view/components/text_fields/fancy_text_field.dart';

import 'package:flutter_beertastic/blocs/authenticator.dart';

import 'package:provider/provider.dart';

class ResetForm extends StatefulWidget {
  @override
  _ResetFormState createState() => _ResetFormState();
}

class _ResetFormState extends State<ResetForm> {
  final TextEditingController _emailTextFieldController =
      TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  FocusNode _snackFocus;

  Authenticator _authBLoC;

  bool logging;

  @override
  Widget build(BuildContext context) {
    _authBLoC = Provider.of<AuthenticatorInterface>(context);
    return StreamBuilder(
      stream: _authBLoC.remoteError,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _showError(context, snapshot.data));
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) =>
              Scaffold.of(context)
                  .removeCurrentSnackBar(reason: SnackBarClosedReason.dismiss));
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
                child: Wrap(
                  children: <Widget>[
                    FancyTextField(
                      _emailTextFieldController,
                      _emailFocus,
                      label: 'Email',
                      icon: Icons.mail_outline,
                      error: _computeEmailError(snapshot.data),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 80.0),
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
                      vertical: 10.0, horizontal: 15.0),
                  child: Text(
                    "RESET PASSWORD",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.headline3.color,
                        fontSize: 25.0,
                        fontFamily: "WorkSansBold"),
                  ),
                ),
                onPressed: () async {
                  bool emailSent = await _authBLoC
                      .sendPasswordResetEmail(_emailTextFieldController.text);
                  if(emailSent)Navigator.pop(context);
                },
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
    _authBLoC = Authenticator();
    _emailFocus
        .addListener(() => {if (_emailFocus.hasFocus) _authBLoC?.resetState()});
  }

  @override
  void dispose() {
    super.dispose();
    _disposeAndUnFocus();
    _emailTextFieldController.dispose();
    _authBLoC.resetState();
    _authBLoC.dispose();
    _snackFocus?.dispose();
  }

  void _disposeAndUnFocus() {
    _emailFocus.unfocus();
    _emailFocus.dispose();
  }

  bool _computeEmailError(RemoteError error) {
    return error == RemoteError.EMAIL_FORMAT ||
        error == RemoteError.USER_NOT_FOUND;
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
    return text == null ? 'Error during login' : text;
  }
}

class _ErrorTextComputer {
  final Map<RemoteError, String> _errorTexts = {
    RemoteError.EMAIL_FORMAT: 'Insert a valid email please!',
    RemoteError.USER_NOT_FOUND: 'User doesn\'t exist! Use sign up instead',
    RemoteError.WRONG_PASSWORD: 'The password is wrong!'
  };

  Map<RemoteError, String> get errorTexts => _errorTexts;
}
