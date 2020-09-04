import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_beertastic/model/beer.dart';
import 'package:synchronized/synchronized.dart';

class LikesBloc {
  final StreamController<bool> _likedBeerController =
      StreamController.broadcast();

  final StreamController<List<Beer>> _likedBeerListController =
      StreamController.broadcast();

  final List<StreamSubscription> _subscriptions = List();

  final List<Beer> _likedBeers = List();

  final Lock _lock =Lock();

  final FirebaseFirestore _firestore;

  final FirebaseAuth _auth;

  LikesBloc():this._auth=FirebaseAuth.instance, this._firestore=FirebaseFirestore.instance;

  LikesBloc.testConstructor(FirebaseAuth auth,FirebaseFirestore firestore):this._auth=auth, this._firestore=firestore;

  Stream<bool> get likedBeerStream => _likedBeerController.stream;

  Stream<List<Beer>> get likedBeerListStream => _likedBeerListController.stream;

  void clearLikedBeerStream() async {
    await _lock.synchronized(() {
      if(!_likedBeerListController.isClosed)_likedBeerController.sink.add(null);
    });
  }

  void verifyIfLiked(String id) async {
    User user = _auth.currentUser;
    DocumentReference beerLikeRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favourites')
        .doc(id);
    _subscriptions.add(beerLikeRef.snapshots().listen((snapshot) async {
      await _lock.synchronized(() {
        if(!_likedBeerListController.isClosed) {
          if (snapshot.data() == null)
            _likedBeerController.sink.add(false);
          else
            _likedBeerController.sink.add(true);
        }
      });
    }));
  }

  Future<void> addToFavourites(Beer beer) async {
    DocumentReference reference =
        _firestore.collection('beers').doc(beer.id);
    User user = _auth.currentUser;
    DocumentReference userRef =
        _firestore.collection('users').doc(user.uid);
    try {
      await userRef.collection('favourites').doc(beer.id).set({
        'beer': reference,
        'date': DateTime.now(),
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> removeFromFavourites(Beer beer) async {
    User user = _auth.currentUser;
    DocumentReference userRef =
        _firestore.collection('users').doc(user.uid);
    try {
      await userRef.collection('favourites').doc(beer.id).delete();
    } catch (e) {
      print(e);
    }
    return null;
  }

  void dispose() async {
    _subscriptions.forEach((subscription) => subscription.cancel());
    await _lock.synchronized(() {
      _likedBeerController.close();
      _likedBeerListController.close();
    });
  }

  void retrieveLikedBeers() async {
    User user = _auth.currentUser;
    DocumentReference userRef =
        _firestore.collection('users').doc(user.uid);

    Stream<QuerySnapshot> queryStream =
        userRef.collection('favourites').snapshots();

    _subscriptions.add(queryStream.listen((query) async {
      int i = 0;
      _likedBeers.clear();
      if(query.docs.length==0) {
        await _lock.synchronized(() {
          if(!_likedBeerListController.isClosed)_likedBeerListController.sink.add(_likedBeers);
        });
      }
      query.docs.forEach((docSnapshot) =>
          (docSnapshot.data()['beer'] as DocumentReference)
              .get()
              .then((beerSnap) async {
            i++;
            _likedBeers.add(Beer.fromSnapshot(beerSnap.data()));
            await _lock.synchronized(() {
              if (i >= query.docs.length && !_likedBeerListController.isClosed) {
                _likedBeerListController.sink.add(_likedBeers);
              }
            });
          }));
    }));
  }
}
