import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beertastic/model/user.dart';

class ProfileImageBloc {
  Uint8List _profileImage;
  final StreamController<ImageProvider> _profileImageController =
  StreamController();

  get profileImage => _profileImage;

  get profileImageStream => _profileImageController.stream;

  void getProfileImage() {
    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance
          .collection('users')
          .document(user.uid)
          .get()
          .then((userSnapshot) => _retrieveProfileImage(userSnapshot.data));
    });
  }

  void _retrieveProfileImage(Map<String, dynamic> snapshot) {
    User user = User.fromSnapshot(snapshot);
    String path = user.profileImagePath;
    if (path == null) {
      _profileImageController.sink.add(AssetImage('assets/images/user.png'));
    } else {
      FirebaseStorage.instance.ref().child(path).getData(100000000)
          .then(
              (uIntImage) =>
              _profileImageController.sink.add(MemoryImage(uIntImage)))
          .catchError((error) => print('image don\'t exist'));
    }
  }

  void dispose() {
    _profileImageController.close();
  }

  Future<String> getProfileImagePath() async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    Future<DocumentSnapshot> futureSnap = Firestore.instance
        .collection('users')
        .document(fUser.uid)
        .get();
    return futureSnap.then((userSnap) =>
    User
        .fromSnapshot(userSnap.data)
        .profileImagePath);
  }
}
