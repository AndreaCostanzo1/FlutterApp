import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class Authenticator {
  final Map<String, RemoteError> errors = {
    'ERROR_USER_NOT_FOUND': RemoteError.USER_NOT_FOUND,
  };

  RemoteError _remoteError;
  final _remoteErrorController = StreamController<RemoteError>();

  Stream<RemoteError> get remoteError => _remoteErrorController.stream;

  Authenticator();

  void logWithEmailAndPassword(String email, String password) {
    RemoteError _staticError = StaticFieldChecker().checkEmailAndPassword(email, password);
    if(_staticError!=null) {
      _remoteErrorController.sink.add(_staticError);
    } else {
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .catchError((error) => _handleError(error));
    }
  }

  //fixme when a more effective way is available
  void _handleError(Exception error) {
    String errorText = error.toString().substring(
        error.toString().indexOf('(') + 1, error.toString().indexOf(','));
    RemoteError remoteError = errors[errorText];
    if (remoteError == null) {
      remoteError = RemoteError.NOT_DEFINED;
      //todo insert logger
    }
    _remoteError = remoteError;
    _remoteErrorController.sink.add(_remoteError);
  }

  void resetError() {
    _remoteError = null;
    _remoteErrorController.sink.add(_remoteError);
  }

  void dispose() {
    _remoteErrorController.close();
  }
}

enum RemoteError {
  USER_NOT_FOUND,
  USER_ALREADY_EXIST,
  EMAIL_FORMAT,
  PASSWORD_FORMAT,
  NOT_DEFINED,
}

class StaticFieldChecker{

  final Pattern _emailPattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  final Pattern _passwordPattern =
      r'^([A-Za-z0-9~`!@#$%^&*()-_+=|}\]{[\"\:;?/>.<,]){6,}$';

  RemoteError checkEmailAndPassword(String email, String password){
    if (email==null||!RegExp(_emailPattern).hasMatch(email)) return RemoteError.EMAIL_FORMAT;
    if (password==null||!RegExp(_passwordPattern).hasMatch(password)) return RemoteError.PASSWORD_FORMAT;
    return null;
  }

}
