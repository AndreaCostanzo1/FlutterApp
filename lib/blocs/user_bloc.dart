import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beertastic/blocs/utilities/city_data_converter.dart';
import 'package:flutter_beertastic/model/city.dart';
import 'package:flutter_beertastic/model/user.dart';

class UserBloc {
  final StreamController<ImageProvider> _profileImageController =
      StreamController();

  final StreamController<User> _authenticatedUserController =
      StreamController.broadcast();

  final StreamController<ImageProvider> _userImageController =
      StreamController.broadcast();

  get profileImageStream => _profileImageController.stream;

  get authenticatedUserStream => _authenticatedUserController.stream;

  get userImageStream => _userImageController.stream;

  void dispose() {
    _profileImageController.close();
    _authenticatedUserController.close();
    _userImageController.close();
  }

  void getUserImage(String path) {
    if (path != null) {
      FirebaseStorage.instance
          .ref()
          .child(path)
          .getData(100000000)
          .then((uIntImage) =>
              _userImageController.sink.add(MemoryImage(uIntImage)))
          .catchError((error) {

        print('image don\'t exist');
        _userImageController.sink
            .add(AssetImage('assets/images/user_review.png'));
      });
    }
  }

  void getAuthenticatedUserData() {
    FirebaseAuth.instance.currentUser().then((fUser) async {
      DocumentSnapshot userSnapshot = await Firestore.instance
          .collection('users')
          .document(fUser.uid)
          .get();
      Map<String, dynamic> userData = userSnapshot.data;
      DocumentReference cityRef = userSnapshot['city'];
      DocumentSnapshot citySnap = await cityRef.get();
      userData.putIfAbsent(
          'city_data', () => City.fromSnapshot(CityDataConverter.convertSnapshot(citySnap.data)));
      User user = User.fromSnapshot(userData);
      _authenticatedUserController.sink.add(user);
      if(_profileImageController.hasListener)_retrieveProfileImage(user);
    });
  }

  void _retrieveProfileImage(User user) {
    String path = user.profileImagePath;
    if (path == null) {
      _profileImageController.sink.add(AssetImage('assets/images/user.png'));
    } else {
      FirebaseStorage.instance
          .ref()
          .child(path)
          .getData(100000000)
          .then((uIntImage) =>
              _profileImageController.sink.add(MemoryImage(uIntImage)))
          .catchError((error) => print('image don\'t exist'));
    }
  }

  Future<String> getProfileImagePath() async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    Future<DocumentSnapshot> futureSnap =
        Firestore.instance.collection('users').document(fUser.uid).get();
    return futureSnap
        .then((userSnap) => User.fromSnapshot(userSnap.data).profileImagePath);
  }

  Future<void> setInformation(String nickname, City city) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentReference cityRef =Firestore.instance.collection('cities').document(city.id);
    return Firestore.instance.collection('users').document(user.uid).updateData({
      'nickname': nickname,
      'city': cityRef
    });
  }
}
