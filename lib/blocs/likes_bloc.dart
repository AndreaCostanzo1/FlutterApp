import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_beertastic/model/beer.dart';

class LikesBloc {
  final StreamController<bool> _beerLikeController =
      StreamController.broadcast();

  final List<StreamSubscription> _subscriptions = List();

  Stream<bool> get beerLikeStream => _beerLikeController.stream;

  void clearStream() {
    _beerLikeController.sink.add(null);
  }

  void verifyIfLiked(String id) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentReference beerLikeRef = Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('favourites')
        .document(id);
    _subscriptions.add(beerLikeRef.snapshots().listen((snapshot) {
      if (snapshot.data == null)
        _beerLikeController.sink.add(false);
      else
        _beerLikeController.sink.add(true);
    }));
  }

  void addToFavourites(Beer beer) async {
    DocumentReference reference =
        Firestore.instance.collection('beers').document(beer.id);
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentReference userRef =
        Firestore.instance.collection('users').document(user.uid);
    try {
      userRef.collection('favourites').document(beer.id).setData({
        'beer': reference,
        'date': DateTime.now(),
      });
    } catch (e) {
      print(e);
    }
  }

  void removeFromFavourites(Beer beer) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentReference userRef =
        Firestore.instance.collection('users').document(user.uid);
    try {
      userRef.collection('favourites').document(beer.id).delete();
    } catch (e) {
      print(e);
    }
  }

  void dispose() {
    _subscriptions.forEach((subscription) => subscription.cancel());
    _beerLikeController.close();
  }
}
