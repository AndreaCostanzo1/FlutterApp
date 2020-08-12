import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  Stream<Beer> get singleBeerController => _singleBeerController.stream;

  void dispose() async {
    _subscriptions.forEach((subscription) => subscription.cancel());
    _beersController?.close();
    _singleBeerController?.close();
  }

  void retrieveSuggestedBeers() {
    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance
          .collection('beers')
          .where('suggestTo',
              arrayContains:
                  Firestore.instance.collection("users").document(user.uid))
          .getDocuments()
          .then((query) => _updateBeersSink(query.documents));
    });
  }

  _updateBeersSink(List<DocumentSnapshot> beersSnapshots) {
    //get the list of articles still not retrieved
    _beers.clear();
    _beers.addAll(beersSnapshots
        .map((snapshots) => Beer.fromSnapshot(snapshots.data))
        .toList());
    _beersController.sink.add(_beers);
  }

  static Stream<Uint8List> getBeerImage(String imageUrl) {
    return FirebaseStorage.instance
        .ref()
        .child(imageUrl ?? 'random')
        .getData(10000000)
        .asStream()
        .asBroadcastStream(); //fixme-> addReference to an ImageNotFound in firebase instead of 'random
  }
}
