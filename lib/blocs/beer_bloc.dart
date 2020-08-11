import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_beertastic/model/beer.dart';

class BeerBloc {
  final List<Beer> _beers = List();

  final List<StreamSubscription> _subscriptions = List();

  //.broadcast used when there are multiple listeners
  final StreamController<List<Beer>> _beersController =
  StreamController<List<Beer>>.broadcast();

  final StreamController<Beer> _singleBeerController =
  StreamController<Beer>.broadcast();

  Stream<List<Beer>> get beersController => _beersController.stream;

  Stream<Beer> get singleBeerController =>
      _singleBeerController.stream;

  void dispose() async {
    _subscriptions.forEach((subscription) => subscription.cancel());
    _beersController?.close();
    _singleBeerController?.close();
  }

  void retrieveSuggestedBeers() {
    _subscriptions.add(Firestore.instance
        .collection('beers')
        .where('suggestTo', arrayContains: FirebaseAuth.instance.currentUser())
        .snapshots()
        .listen((query) => _updateBeersSink(query.documents)));
  }

  _updateBeersSink(List<DocumentSnapshot> beersSnapshots) {
    //get the list of articles still not retrieved
    _beers.clear();
    _beers.addAll(beersSnapshots
        .map((snapshots) => Beer.fromSnapshot(snapshots.data))
        .toList());
    _beersController.sink.add(_beers);
  }
}