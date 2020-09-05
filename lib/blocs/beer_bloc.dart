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

  final Lock _lock = Lock(reentrant: true);

  DocumentSnapshot _lastDocument;

  final FirebaseFirestore _firestore;

  final FirebaseAuth _firebaseAuth;

  final CloudFunctions _functions;

  static const int _queryLimit = 9;

  bool _noMoreBeerAvailable;

  BeerBloc.testConstructor(FirebaseFirestore firestoreMock,
      FirebaseAuth authMock, CloudFunctions functionsMock)
      : this._firestore = firestoreMock,
        this._firebaseAuth = authMock,
        this._functions = functionsMock {
    _cachedBeers.addAll({
      _suggestedBeersController: List(),
      _queriedBeersController: List(),
    });
    _noMoreBeerAvailable = false;
  }

  BeerBloc()
      : this._firestore = FirebaseFirestore.instance,
        this._firebaseAuth = FirebaseAuth.instance,
        this._functions = CloudFunctions.instance {
    _cachedBeers.addAll({
      _suggestedBeersController: List(),
      _queriedBeersController: List(),
    });
    _noMoreBeerAvailable = false;
  }

  static int get queryLimit => _queryLimit;

  Stream<List<Beer>> get suggestedBeersStream =>
      _suggestedBeersController.stream;

  Stream<Beer> get singleBeerStream => _singleBeerController.stream;

  Stream<List<Beer>> get queriedBeersStream => _queriedBeersController.stream;

  List<Beer> get suggestedBeers => _cachedBeers[_suggestedBeersController];

  List<Beer> get queriedBeers => _cachedBeers[_queriedBeersController];

  bool get noMoreBeerAvailable => _noMoreBeerAvailable;

  Future<void> dispose() async {
    await _lock.synchronized(() {
      _subscriptions.forEach((subscription) => subscription.cancel());
      _suggestedBeersController.close();
      _singleBeerController.close();
      _queriedBeersController.close();
    });
    return null;
  }

  Future<void> retrieveSuggestedBeers() async {
    if (_suggestedBeersController.isClosed) return;
    User user = _firebaseAuth.currentUser;
    QuerySnapshot query = await _firestore
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
    await _firestore
        .collection('beers')
        .where('cluster_code', arrayContainsAny: affinities)
        .orderBy('id')
        .limit(_queryLimit)
        .get()
        .then((query) async {
      await _lock.synchronized(() {
        if (query.docs.length > 0) {
          _lastDocument = query.docs.last;
        }
        _noMoreBeerAvailable = query.docs.length < _queryLimit;
        _updateBeersSink(_suggestedBeersController, query.docs);
      });
    });
    return null;
  }

  void retrieveMoreSuggestedBeers() async {
    DocumentSnapshot lastDoc;
    await _lock.synchronized(() {
      if (_lastDocument != null) {
        lastDoc = _lastDocument;
        _lastDocument = null;
      }
    });
    if (!_noMoreBeerAvailable && lastDoc != null) {
      User user = _firebaseAuth.currentUser;
      QuerySnapshot query = await _firestore
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
      _firestore
          .collection('beers')
          .where('cluster_code', arrayContainsAny: affinities)
          .orderBy('id')
          .limit(_queryLimit)
          .startAfterDocument(lastDoc)
          .get()
          .then((query) async {
        await _lock.synchronized(() {
          if (query.docs.length > 0) _lastDocument = query.docs.last;
          if (query.docs.length < _queryLimit) _noMoreBeerAvailable = true;
          _updateBeersSinkWithoutClear(_suggestedBeersController, query.docs);
        });
      });
    }
  }

  //value is used to perform a "like" behaviour of SQL databases
  void retrieveBeersWhenParameterIsLike(String parameter, String value) {
    if (_queriedBeersController.isClosed) return;
    String lowerLimit = (value.length > 0 ? value[0].toUpperCase() : '');
    if (value.length > 1)
      lowerLimit = lowerLimit + value.substring(1).toLowerCase();
    String upperLimit = lowerLimit + '~';
    _firestore
        .collection('beers')
        .where(parameter, isGreaterThanOrEqualTo: lowerLimit)
        .where(parameter, isLessThanOrEqualTo: upperLimit)
        .limit(5)
        .get()
        .then((query) => _updateBeersSink(_queriedBeersController, query.docs));
  }

  _updateBeersSink(StreamController<List<Beer>> beersStream,
      List<DocumentSnapshot> beersSnapshots) async {
    //get the list of beers still not retrieved
    await _lock.synchronized(() {
      if (!beersStream.isClosed) {
        _cachedBeers[beersStream].clear();
        _cachedBeers[beersStream].addAll(beersSnapshots
            .map((snapshots) => Beer.fromSnapshot(snapshots.data()))
            .toList());
        beersStream.sink.add(_cachedBeers[beersStream]);
      }
    });
  }

  void clearQueriedBeersStream() async {
    await _lock.synchronized(() {
      _cachedBeers[_queriedBeersController].clear();
      if (!_queriedBeersController.isClosed)
        _queriedBeersController.sink.add(_cachedBeers[_queriedBeersController]);
    });
  }

  void retrieveSingleBeer(String beerID) {
    _firestore.collection('beers').doc(beerID).get().then((snapshot) async {
      if (snapshot.data() != null) {
        await _lock.synchronized(() {
          if (!_singleBeerController.isClosed)
            _singleBeerController.sink.add(Beer.fromSnapshot(snapshot.data()));
        });
      } else {
        await _lock.synchronized(() {
          if (!_singleBeerController.isClosed) {
            _singleBeerController.sink.addError('Beer-not-found');
            _singleBeerController.sink.add(Beer.nullBeer());
          }
        });
      }
    });
  }

  void updateSearches(String id) async {
    DocumentReference reference = _firestore.collection('beers').doc(id);
    User user = _firebaseAuth.currentUser;
    DocumentReference userRef = _firestore.collection('users').doc(user.uid);
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
      _functions
          .getHttpsCallable(
        functionName: 'updateSearches',
      )
          .call({'beerId': id});
    }
  }

  Future<void> addToFavourites(Beer beer) async {
    DocumentReference reference = _firestore.collection('beers').doc(beer.id);
    User user = _firebaseAuth.currentUser;
    DocumentReference userRef = _firestore.collection('users').doc(user.uid);
    await _lock.synchronized(() async {
      if (!_singleBeerController.isClosed) _singleBeerController.sink.add(null);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(reference);
        int newLikes = snapshot.data()['likes'] + 1;
        transaction.update(reference, {'likes': newLikes});
        return newLikes;
      });
    });
    try {
      await reference.collection('favourites').doc(user.uid).set({
        'user': userRef,
        'date': DateTime.now(),
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> removeFromFavourites(Beer beer) async {
    DocumentReference reference = _firestore.collection('beers').doc(beer.id);
    User user = _firebaseAuth.currentUser;
    await _lock.synchronized(() async {
      if (!_singleBeerController.isClosed) _singleBeerController.sink.add(null);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(reference);
        int newLikes = snapshot.data()['likes'] - 1;
        transaction.update(reference, {'likes': newLikes});
        return newLikes;
      });
    });
    try {
      reference.collection('favourites').doc(user.uid).delete();
    } catch (e) {
      print(e);
    }
    return null;
  }

  void observeSingleBeer(String beerID) {
    _subscriptions.add(_firestore
        .collection('beers')
        .doc(beerID)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.data() != null) {
        await _lock.synchronized(() {
          if (!_singleBeerController.isClosed)
            _singleBeerController.sink.add(Beer.fromSnapshot(snapshot.data()));
        });
      } else {
        await _lock.synchronized(() {
          if (!_singleBeerController.isClosed) {
            _singleBeerController.sink.addError('Beer-not-found');
            _singleBeerController.sink.add(Beer.nullBeer());
          }
        });
      }
    }));
  }

  void _updateBeersSinkWithoutClear(
      StreamController<List<Beer>> beersStreamController,
      List<QueryDocumentSnapshot> docs) async {
    await _lock.synchronized(() {
      if (!beersStreamController.isClosed) {
        _cachedBeers[beersStreamController].addAll(docs
            .map((snapshots) => Beer.fromSnapshot(snapshots.data()))
            .toList());
        beersStreamController.sink.add(_cachedBeers[beersStreamController]);
      }
    });
  }
}
