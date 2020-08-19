import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthenticatorInterface {
  void logWithEmailAndPassword(String email, String password);

  void signUpWithEmailAndPassword(String email, String password,
      String confirm);

  void logOut();

  void resetState();

  void dispose();

  Stream<RemoteError> get remoteError;
}

class Authenticator implements AuthenticatorInterface {
  final Map<String, RemoteError> errors = {
    'ERROR_USER_NOT_FOUND': RemoteError.USER_NOT_FOUND,
    'ERROR_WRONG_PASSWORD': RemoteError.WRONG_PASSWORD,
  };

  RemoteError _remoteError;
  final StreamController<RemoteError> _remoteErrorController = StreamController<
      RemoteError>.broadcast(); //.broadcast used when there are multiple listeners

  Authenticator();

  @override
  Stream<RemoteError> get remoteError => _remoteErrorController.stream;

  @override
  void logWithEmailAndPassword(String email, String password) async {
    RemoteError _staticError =
    StaticFieldChecker().checkEmailAndPassword(email, password);
    if (_staticError != null) {
      _remoteErrorController.sink.add(_staticError);
    } else {
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .catchError((error) => _handleError(error));
    }
  }

  @override
  void signUpWithEmailAndPassword(String email, String password,
      String confirm) async {
    RemoteError _staticError =
    StaticFieldChecker().checkFields(email, password, confirm);
    if (_staticError != null) {
      _remoteErrorController.sink.add(_staticError);
    } else {
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((response) => _createNewUserEntry(response))
          .catchError((error) => _handleError(error));
    }
  }

  @override
  void logOut() {
    FirebaseAuth.instance.signOut().catchError((error) => _handleError(error));
  }

  //fixme when a more effective way is available
  void _handleError(Exception error) async {
    String errorText = error.toString().substring(
        error.toString().indexOf('(') + 1, error.toString().indexOf(','));
    RemoteError remoteError = errors[errorText];
    if (remoteError == null) {
      remoteError = RemoteError.NOT_DEFINED;
      print(remoteError);
      //todo insert firebase logger
    }
    _remoteError = remoteError;
    _remoteErrorController.sink.add(_remoteError);
  }

  @override
  void resetState() async {
    _remoteError = null;
    _remoteErrorController.sink.add(_remoteError);
  }

  void dispose() async {
    _remoteErrorController?.close();
  }

  void _createNewUserEntry(AuthResult response) async {
    FirebaseUser user = response.user;
    Map<String, dynamic> userData = Map.from({
      'id': user.uid,
      'nickname': 'user' + user.uid.substring(10),
      'email': user.email,
      'profile_image_path': 'profile_images/' + user.uid
    });
    DocumentReference userRef=Firestore.instance.collection('users').document(user.uid);
    userRef.setData(userData);
    QuerySnapshot query = await Firestore.instance.collection('clusters').orderBy(
        'popularity', descending: true).limit(1).getDocuments();
    DocumentSnapshot clusterSnap = query.documents.first;
    userRef.collection('affinities').document(clusterSnap.documentID).setData({
      'cluster_code': Firestore.instance.collection('clusters').document(clusterSnap.documentID),
      'affinity': 0.5
    });
  }
}

enum RemoteError {
  USER_NOT_FOUND,
  USER_ALREADY_EXIST,
  EMAIL_FORMAT,
  PASSWORD_FORMAT,
  NOT_MATCHING_PASSWORDS,
  WRONG_PASSWORD,
  NOT_DEFINED,
}

class StaticFieldChecker {
  final Pattern _emailPattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  final Pattern _passwordPattern =
      r'^([A-Za-z0-9~`!@#$%^&*()-_+=|}\]{[\"\:;?/>.<,]){6,}$';

  RemoteError checkEmailAndPassword(String email, String password) {
    if (email == null || !RegExp(_emailPattern).hasMatch(email))
      return RemoteError.EMAIL_FORMAT;
    if (password == null || !RegExp(_passwordPattern).hasMatch(password))
      return RemoteError.PASSWORD_FORMAT;
    return null;
  }

  RemoteError checkFields(String email, String password, String confirm) {
    RemoteError error = checkEmailAndPassword(email, password);
    return error != null
        ? error
        : password != confirm ? RemoteError.NOT_MATCHING_PASSWORDS : null;
  }
}
