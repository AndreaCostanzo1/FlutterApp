import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final Lock _lock = Lock();

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
    _suggestedBeersController.close();
    _singleBeerController.close();
    _queriedBeersController.close();
  }

  void retrieveSuggestedBeers() async {
    if (_suggestedBeersController.isClosed) return;
    User user = FirebaseAuth.instance.currentUser;
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('affinities')
        .where('affinity', isGreaterThanOrEqualTo: 0.5)
        .orderBy('affinity', descending: true)
        .limit(10)
        .get();
    List<DocumentReference> affinities = List();
    query.docs
        .forEach((element) => affinities.add(element.data()['cluster_code']));
    FirebaseFirestore.instance
        .collection('beers')
        .where('cluster_code', arrayContainsAny: affinities)
        .get()
        .then(
            (query) => _updateBeersSink(_suggestedBeersController, query.docs));
  }

  //value is used to perform a "like" behaviour of SQL databases
  void retrieveBeersWhenParameterIsLike(String parameter, String value) {
    if (_queriedBeersController.isClosed) return;
    String lowerLimit = (value.length > 0 ? value[0].toUpperCase() : '');
    if (value.length > 1)
      lowerLimit = lowerLimit + value.substring(1).toLowerCase();
    String upperLimit = lowerLimit + '~';
    FirebaseFirestore.instance
        .collection('beers')
        .where(parameter, isGreaterThanOrEqualTo: lowerLimit)
        .where(parameter, isLessThanOrEqualTo: upperLimit)
        .get()
        .then((query) => _updateBeersSink(_queriedBeersController, query.docs));
  }

  _updateBeersSink(StreamController<List<Beer>> beersStream,
      List<DocumentSnapshot> beersSnapshots) {
    //get the list of articles still not retrieved
    if (!beersStream.isClosed) {
      List<Beer> beerList = _cachedBeers[beersStream];
      beerList.clear();
      beerList.addAll(beersSnapshots
          .map((snapshots) => Beer.fromSnapshot(snapshots.data()))
          .toList());
      beersStream.sink.add(beerList);
    }
  }


  void clearQueriedBeersStream() {
    List<Beer> beerList = _cachedBeers[_queriedBeersController];
    beerList.clear();
    _queriedBeersController.sink.add(beerList);
  }

  void retrieveSingleBeer(String beerID) {
    FirebaseFirestore.instance
        .collection('beers')
        .doc(beerID)
        .get()
        .then((snapshot) {
      if (snapshot.data() != null) {
        _singleBeerController.sink.add(Beer.fromSnapshot(snapshot.data()));
      } else {
        _singleBeerController.sink.addError('Beer-not-found');
        _singleBeerController.sink.add(Beer.nullBeer());
      }
    });
  }

  void updateSearches(String id) async {
    DocumentReference reference =
        FirebaseFirestore.instance.collection('beers').doc(id);
    User user = FirebaseAuth.instance.currentUser;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    QuerySnapshot query = await reference
        .collection('searches')
        .where('user', isEqualTo: userRef)
        .where('date',
            isGreaterThan: DateTime.now().subtract(Duration(minutes: 2)))
        .get();
    if (query.docs != null && !(query.docs.length > 0)) {
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
        FirebaseFirestore.instance.collection('beers').doc(beer.id);
    User user = FirebaseAuth.instance.currentUser;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    _singleBeerController.sink.add(null);
    await _lock.synchronized(() async {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(reference);
        transaction.update(reference, {'likes': snapshot.data()['likes'] + 1});
      });
    });
    try {
      reference.collection('favourites').doc(user.uid).set({
        'user': userRef,
        'date': DateTime.now(),
      });
    } catch (e) {
      print(e);
    }
  }

  void removeFromFavourites(Beer beer) async {
    DocumentReference reference =
        FirebaseFirestore.instance.collection('beers').doc(beer.id);
    User user = FirebaseAuth.instance.currentUser;
    _singleBeerController.sink.add(null);
    await _lock.synchronized(() async {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(reference);
        transaction.update(reference, {'likes': snapshot.data()['likes'] - 1});
      });
    });
    try {
      reference.collection('favourites').doc(user.uid).delete();
    } catch (e) {
      print(e);
    }
  }

  void observeSingleBeer(String beerID) {
    _subscriptions.add(FirebaseFirestore.instance
        .collection('beers')
        .doc(beerID)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.data() != null) {
        _singleBeerController.sink.add(Beer.fromSnapshot(snapshot.data()));
      } else {
        _singleBeerController.sink.addError('Beer-not-found');
        _singleBeerController.sink.add(Beer.nullBeer());
      }
    }));
  }
}
