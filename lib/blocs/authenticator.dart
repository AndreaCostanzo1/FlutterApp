import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_beertastic/blocs/map_bloc.dart';

abstract class AuthenticatorInterface {
  void logWithEmailAndPassword(String email, String password);

  void signUpWithEmailAndPassword(
      String email, String password, String confirm);

  Future<bool> sendPasswordResetEmail(String email);

  void logOut();

  void resetState();

  void dispose();

  Future<void > deleteAccount();

  Stream<RemoteError> get remoteError;
}

class Authenticator implements AuthenticatorInterface {
  final Map<String, RemoteError> errors = {
    'user-not-found': RemoteError.USER_NOT_FOUND,
    'wrong-password': RemoteError.WRONG_PASSWORD,
    'email-already-in-use': RemoteError.USER_ALREADY_EXIST,
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
      try{
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch(error){
        _handleError(error);
      }
    }
  }

  @override
  void signUpWithEmailAndPassword(
      String email, String password, String confirm) async {
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

  @override
  Future<void> deleteAccount() async {
    return FirebaseAuth.instance.currentUser.delete();
  }

  @override
  Future<bool> sendPasswordResetEmail(String email) async{
    RemoteError _staticError= StaticFieldChecker().checkEmail(email);
    if (_staticError != null) {
      _remoteErrorController.sink.add(_staticError);
      return false;
    } else {
      try{
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: email);
        return true;
      } on FirebaseAuthException catch(error){
        _handleError(error);
        return false;
      }
    }
  }

  void _handleError(FirebaseAuthException error) async {
    print(error.code);
    RemoteError remoteError = errors[error.code];
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

  void _createNewUserEntry(UserCredential response) async {
    User user = response.user;
    await _createDatabaseEntry(user);
    _setUserDefaultCity(user);
    _setUserBeerAffinities(user);
  }

  Future<void> _createDatabaseEntry(User user) async {
    Map<String, dynamic> userData = Map.from({
      'id': user.uid,
      'nickname': 'user' + user.uid.substring(16),
      'email': user.email,
      'profile_image_path': 'profile_images/' + user.uid
    });
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    return userRef.set(userData);
  }

  void _setUserDefaultCity(User user) {
    MapBloc bloc = MapBloc();
    bloc.setDefaultCity(user);
    bloc.dispose();
  }

  void _setUserBeerAffinities(User user) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('clusters')
        .orderBy('popularity', descending: true)
        .limit(1)
        .get();
    //take the cluster with higher popularity
    DocumentSnapshot clusterSnap = query.docs.first;
    userRef.collection('affinities').doc(clusterSnap.id).set({
      'cluster_code':
          FirebaseFirestore.instance.collection('clusters').doc(clusterSnap.id),
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

  RemoteError checkEmail(String email){
    if (email == null || !RegExp(_emailPattern).hasMatch(email))
      return RemoteError.EMAIL_FORMAT;
    return null;
  }

  RemoteError checkEmailAndPassword(String email, String password) {
    RemoteError emailError= checkEmail(email);
    return emailError != null
        ? emailError
        :password==null || !RegExp(_passwordPattern).hasMatch(password)?RemoteError.PASSWORD_FORMAT:null;
  }

  RemoteError checkFields(String email, String password, String confirm) {
    RemoteError error = checkEmailAndPassword(email, password);
    return error != null
        ? error
        : password != confirm ? RemoteError.NOT_MATCHING_PASSWORDS : null;
  }
}
