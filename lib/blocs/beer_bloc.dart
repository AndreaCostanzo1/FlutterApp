import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_beertastic/model/beer.dart';

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
    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance
          .collection('beers')
          .where('suggestTo',
              arrayContains:
                  Firestore.instance.collection("users").document(user.uid))
          .getDocuments()
          .then((query) =>
              _updateBeersSink(_suggestedBeersController, query.documents));
    });
  }

  //value is used to perform a "like" behaviour of SQL databases
  void retrieveBeersWhenParameterIsLike(String parameter, String value) {
    if (_queriedBeersController.isClosed) return;
    String lowerLimit=(value.length>0?value[0].toUpperCase():'');
    if(value.length>1) lowerLimit=lowerLimit+value.substring(1).toLowerCase();
    String upperLimit=lowerLimit+'zzzz';
    Firestore.instance
        .collection('beers')
        .where(parameter,
           isGreaterThanOrEqualTo: lowerLimit)
        .where(parameter,isLessThanOrEqualTo: upperLimit)
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
      beerList.forEach((element) {print(element.name);}); //fixme remove me
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
}


