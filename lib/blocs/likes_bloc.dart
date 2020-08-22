import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_beertastic/model/beer.dart';

class LikesBloc {
  final StreamController<bool> _likedBeerController =
      StreamController.broadcast();

  final StreamController<List<Beer>> _likedBeerListController =
      StreamController.broadcast();

  final List<StreamSubscription> _subscriptions = List();

  final List<Beer> _likedBeers = List();

  Stream<bool> get likedBeerStream => _likedBeerController.stream;

  Stream<List<Beer>> get likedBeerListStream => _likedBeerListController.stream;

  void clearLikedBeerStream() {
    _likedBeerController.sink.add(null);
  }

  void verifyIfLiked(String id) async {
    User user = FirebaseAuth.instance.currentUser;
    DocumentReference beerLikeRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favourites')
        .doc(id);
    _subscriptions.add(beerLikeRef.snapshots().listen((snapshot) {
      if (snapshot.data == null)
        _likedBeerController.sink.add(false);
      else
        _likedBeerController.sink.add(true);
    }));
  }

  void addToFavourites(Beer beer) async {
    DocumentReference reference =
        FirebaseFirestore.instance.collection('beers').doc(beer.id);
    User user = FirebaseAuth.instance.currentUser;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    try {
      userRef.collection('favourites').doc(beer.id).set({
        'beer': reference,
        'date': DateTime.now(),
      });
    } catch (e) {
      print(e);
    }
  }

  void removeFromFavourites(Beer beer) async {
    User user = FirebaseAuth.instance.currentUser;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    try {
      userRef.collection('favourites').doc(beer.id).delete();
    } catch (e) {
      print(e);
    }
  }

  void dispose() {
    _subscriptions.forEach((subscription) => subscription.cancel());
    _likedBeerController.close();
    _likedBeerListController.close();
  }

  void retrieveLikedBeers() async {
    User user = FirebaseAuth.instance.currentUser;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    Stream<QuerySnapshot> queryStream =
        userRef.collection('favourites').snapshots();

    _subscriptions.add(queryStream.listen((query) {
      int i = 0;
      _likedBeers.clear();
      query.docs.forEach((docSnapshot) =>
          (docSnapshot.data()['beer'] as DocumentReference)
              .get()
              .then((beerSnap) {
            i++;
            _likedBeers.add(Beer.fromSnapshot(beerSnap.data()));
            if (i >= query.docs.length && !_likedBeerListController.isClosed) {
              _likedBeerListController.sink.add(_likedBeers);
            }
          }));
    }));
  }
}
