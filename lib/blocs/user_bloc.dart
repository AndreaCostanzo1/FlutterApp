import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beertastic/blocs/utilities/city_data_converter.dart';
import 'package:flutter_beertastic/model/city.dart';
import 'package:flutter_beertastic/model/user.dart';
import 'package:synchronized/synchronized.dart';

class UserBloc {
  final StreamController<ImageProvider> _profileImageController =
      StreamController();

  final StreamController<MyUser> _authenticatedUserController =
      StreamController.broadcast();

  final StreamController<ImageProvider> _userImageController =
      StreamController.broadcast();

  final List<StreamSubscription> _subscriptions = List();

  static const String _imageNotExistError = 'image don\'t exist';

  static String get imageNotFoundError => _imageNotExistError;

  get profileImageStream => _profileImageController.stream;

  get authenticatedUserStream => _authenticatedUserController.stream;

  get userImageStream => _userImageController.stream;

  Lock _lock = Lock();

  final FirebaseAuth _auth;

  final FirebaseFirestore _firestore;

  final FirebaseStorage _storage;

  UserBloc()
      : _firestore = FirebaseFirestore.instance,
        _storage = FirebaseStorage.instance,
        _auth = FirebaseAuth.instance;

  UserBloc.testConstructor(
      FirebaseAuth auth, FirebaseFirestore firestore, FirebaseStorage storage)
      : _firestore = firestore,
        _storage = storage,
        _auth = auth;

  void dispose() async {
    await _lock.synchronized(() {
      _subscriptions.forEach((subscription) => subscription.cancel());
      _profileImageController.close();
      _authenticatedUserController.close();
      _userImageController.close();
    });
  }

  void getUserImage(String path) {
    if (path != null) {
      _storage
          .ref()
          .child(path)
          .getData(1000000)
          .then((uIntImage) => _lock.synchronized(() {
                if (!_userImageController.isClosed)
                  _userImageController.sink.add(MemoryImage(uIntImage));
              }))
          .catchError((error) {
        print('image don\'t exist');
        _lock.synchronized(() {
          if (!_userImageController.isClosed)
            _userImageController.sink
                .add(AssetImage('assets/images/user_review.png'));
        });
      });
    }
  }

  void getAuthenticatedUserData() async {
    User fUser = _auth.currentUser;
    DocumentReference userRef = _firestore.collection('users').doc(fUser.uid);
    DocumentSnapshot userSnapshot = await userRef.get();
    Map<String, dynamic> userData = userSnapshot.data();
    //usually skipped: may happen that, upon registration, the page is uploaded
    //before the default city is set.
    while (userData == null || (userData != null && userData['city'] == null)) {
      userSnapshot = await userRef.get();
      userData.addAll(userSnapshot.data());
      await Future.delayed(Duration(milliseconds: 100));
    }
    DocumentReference cityRef = userSnapshot.data()['city'];
    DocumentSnapshot citySnap = await cityRef.get();
    userData.putIfAbsent(
        'city_data',
        () => City.fromSnapshot(
            CityDataConverter.convertSnapshot(citySnap.data())));
    MyUser user = MyUser.fromSnapshot(userData);
    _lock.synchronized(() {
      if (!_authenticatedUserController.isClosed)
        _authenticatedUserController.sink.add(user);
    });
    if (_profileImageController.hasListener) _retrieveProfileImage(user);
  }

  void _retrieveProfileImage(MyUser user) {
    String path = user.profileImagePath;
    if (path == null) {
      _lock.synchronized(() {
        if (!_profileImageController.isClosed)
          print('here');
          _profileImageController.sink
              .add(AssetImage('assets/images/user.png'));
      });
    } else {
      _storage
          .ref()
          .child(path)
          .getData(1000000)
          .then((uIntImage) => _lock.synchronized(() {
                if (!_profileImageController.isClosed)
                  _profileImageController.sink.add(MemoryImage(uIntImage));
              }))
          .catchError((error) => _lock.synchronized(() {
        if (!_profileImageController.isClosed)
          _profileImageController.sink.addError(_imageNotExistError);
      }));
    }
  }

  Future<String> getProfileImagePath() async {
    User fUser = _auth.currentUser;
    Future<DocumentSnapshot> futureSnap =
        _firestore.collection('users').doc(fUser.uid).get();
    return futureSnap.then(
        (userSnap) => MyUser.fromSnapshot(userSnap.data()).profileImagePath);
  }

  Future<void> setInformation(String nickname, City city) async {
    User user = _auth.currentUser;
    DocumentReference cityRef = _firestore.collection('cities').doc(city.id);
    return _firestore
        .collection('users')
        .doc(user.uid)
        .update({'nickname': nickname, 'city': cityRef});
  }

  void listenToAuthenticatedUserData() async {
    User fUser = _auth.currentUser;
    DocumentReference userRef = _firestore.collection('users').doc(fUser.uid);
    _subscriptions.add(userRef.snapshots().listen((userSnapshot) async {
      Map<String, dynamic> userData = userSnapshot.data();
      //usually skipped: may happen that, upon registration, the page is uploaded
      //before the default city is set.
      while (
          userData == null || (userData != null && userData['city'] == null)) {
        userSnapshot = await userRef.get();
        userData.addAll(userSnapshot.data());
        await Future.delayed(Duration(milliseconds: 100));
      }
      DocumentReference cityRef = userSnapshot.data()['city'];
      DocumentSnapshot citySnap = await cityRef.get();
      userData.putIfAbsent(
          'city_data',
          () => City.fromSnapshot(
              CityDataConverter.convertSnapshot(citySnap.data())));
      MyUser user = MyUser.fromSnapshot(userData);
      _lock.synchronized(() {
        if (!_authenticatedUserController.isClosed)
          _authenticatedUserController.sink.add(user);
      });
      if (_profileImageController.hasListener) _retrieveProfileImage(user);
    }));
  }
}
