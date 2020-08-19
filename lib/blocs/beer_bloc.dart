import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_beertastic/model/beer.dart';
import 'package:synchronized/synchronized.dart';

class BeerBloc {
  final Map<StreamController, List<Beer>> _cachedBeers = Map();

  final List<StreamSubscription> _subscriptions = List();

  //.broadcast used when there are multiple listeners
  final StreamController<List<Beer>> _suggestedBeersController =
      StreamController.broadcast();

  final StreamController<List<Beer>> _queriedBeersController =
      StreamController.broadcast();

  final StreamController<Beer> _singleBeerController =
      StreamController.broadcast();

  final Lock _lock=Lock();

  BeerBloc() {
    _cachedBeers.addAll({
      _suggestedBeersController: List(),
      _queriedBeersController: List(),
    });
  }

  Stream<List<Beer>> get suggestedBeersStream =>
      _suggestedBeersController.stream;

  Stream<Beer> get singleBeerStream => _singleBeerController.stream;

  Stream<List<Beer>> get queriedBeersStream => _queriedBeersController.stream;

  List<Beer> get suggestedBeers => _cachedBeers[_suggestedBeersController];

  List<Beer> get queriedBeers => _cachedBeers[_queriedBeersController];

  void dispose() async {
    _subscriptions.forEach((subscription) => subscription.cancel());
    _suggestedBeersController?.close();
    _singleBeerController?.close();
    _queriedBeersController?.close();
  }

  void retrieveSuggestedBeers() {
    if (_suggestedBeersController.isClosed) return;
    FirebaseAuth.instance.currentUser().then((user) async {
      QuerySnapshot query = await Firestore.instance
          .collection('users')
          .document(user.uid)
          .collection('affinities')
          .where('affinity', isGreaterThanOrEqualTo: 0.5)
          .orderBy('affinity',descending: true)
          .limit(10)
          .getDocuments();
      List<DocumentReference> affinities = List();
      query.documents
          .forEach((element) => affinities.add(element['cluster_code']));
      Firestore.instance
          .collection('beers')
          .where('cluster_code', arrayContainsAny: affinities)
          .getDocuments()
          .then((query) =>
              _updateBeersSink(_suggestedBeersController, query.documents));
    });
  }

  //value is used to perform a "like" behaviour of SQL databases
  void retrieveBeersWhenParameterIsLike(String parameter, String value) {
    if (_queriedBeersController.isClosed) return;
    String lowerLimit = (value.length > 0 ? value[0].toUpperCase() : '');
    if (value.length > 1)
      lowerLimit = lowerLimit + value.substring(1).toLowerCase();
    String upperLimit = lowerLimit + 'zzzz';
    Firestore.instance
        .collection('beers')
        .where(parameter, isGreaterThanOrEqualTo: lowerLimit)
        .where(parameter, isLessThanOrEqualTo: upperLimit)
        .getDocuments()
        .then((query) =>
            _updateBeersSink(_queriedBeersController, query.documents));
  }

  _updateBeersSink(StreamController<List<Beer>> beersStream,
      List<DocumentSnapshot> beersSnapshots) {
    //get the list of articles still not retrieved
    if (!beersStream.isClosed) {
      List<Beer> beerList = _cachedBeers[beersStream];
      beerList.clear();
      beerList.addAll(beersSnapshots
          .map((snapshots) => Beer.fromSnapshot(snapshots.data))
          .toList());
      beersStream.sink.add(beerList);
    }
  }

  static Stream<Uint8List> getBeerImage(String imageUrl) {
    return FirebaseStorage.instance
        .ref()
        .child(imageUrl ?? 'random')
        .getData(10000000)
        .asStream()
        .asBroadcastStream(); //fixme-> addReference to an ImageNotFound in firebase instead of 'random
  }

  void clearQueriedBeersStream() {
    List<Beer> beerList = _cachedBeers[_queriedBeersController];
    beerList.clear();
    _queriedBeersController.sink.add(beerList);
  }

  void retrieveSingleBeer(String beerID) {
    Firestore.instance
        .collection('beers')
        .document(beerID)
        .get()
        .then((snapshot) {
      if (snapshot.data != null) {
        _singleBeerController.sink.add(Beer.fromSnapshot(snapshot.data));
      } else {
        _singleBeerController.sink.addError('Beer-not-found');
        _singleBeerController.sink.add(Beer.nullBeer());
      }
    });
  }

  void updateSearches(String id) async {
    DocumentReference reference =
        Firestore.instance.collection('beers').document(id);
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentReference userRef =
        Firestore.instance.collection('users').document(user.uid);
    QuerySnapshot query = await reference
        .collection('searches')
        .where('user', isEqualTo: userRef)
        .where('date',
            isGreaterThan: DateTime.now().subtract(Duration(minutes: 2)))
        .getDocuments();
    if (query.documents != null && !(query.documents.length > 0)) {
      reference.collection('searches').add({
        'user': userRef,
        'date': DateTime.now(),
      });
      CloudFunctions.instance
          .getHttpsCallable(
        functionName: 'updateSearches',
      )
          .call({'beerId': id});
    }
  }

  void addToFavourites(Beer beer) async {
    DocumentReference reference =
        Firestore.instance.collection('beers').document(beer.id);
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentReference userRef =
        Firestore.instance.collection('users').document(user.uid);
    _singleBeerController.sink.add(null);
    await _lock.synchronized(() async {
      await Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(reference);
        transaction.update(reference, {'likes': snapshot.data['likes'] + 1});
      });
    });
    try {
      reference.collection('favourites').document(user.uid).setData({
        'user': userRef,
        'date': DateTime.now(),
      });
    } catch (e) {
      print(e);
    }
  }

  void removeFromFavourites(Beer beer) async {
    DocumentReference reference =
        Firestore.instance.collection('beers').document(beer.id);
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    _singleBeerController.sink.add(null);
    await _lock.synchronized(() async {
      await Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(reference);
        transaction.update(reference, {'likes': snapshot.data['likes'] - 1});
      });
    });
    try {
      reference.collection('favourites').document(user.uid).delete();
    } catch (e) {
      print(e);
    }

  }

  void observeSingleBeer(String beerID) {
    _subscriptions.add(Firestore.instance
        .collection('beers')
        .document(beerID)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.data != null) {
        _singleBeerController.sink.add(Beer.fromSnapshot(snapshot.data));
      } else {
        _singleBeerController.sink.addError('Beer-not-found');
        _singleBeerController.sink.add(Beer.nullBeer());
      }
    }));
  }
}
