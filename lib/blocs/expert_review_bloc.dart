import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_beertastic/model/beer.dart';
import 'package:flutter_beertastic/model/expert_review.dart';

class ExpertReviewBloc {
  final StreamController<ExpertReview> _reviewController =
      StreamController.broadcast();

  Stream<ExpertReview> get reviewStream => _reviewController.stream;

  static const String _notFoundError = 'Beer-not-found';

  final FirebaseFirestore _firestore;

  ExpertReviewBloc():_firestore=FirebaseFirestore.instance;

  ExpertReviewBloc.testConstructor(FirebaseFirestore firestore): _firestore=firestore;

  static String get notFoundError => _notFoundError;

  void dispose() async {
    _reviewController?.close();
  }

  Future<void> retrieveReview(Beer beer) async {
    DocumentSnapshot beerSnap =
        await _firestore.collection('beers').doc(beer.id).get();
    if (beerSnap.data() != null) {
      DocumentReference reviewRef = beerSnap.data()['expert_review'];
      reviewRef.get().then((snapshot) {
        if (snapshot.data() != null) {
          _reviewController.sink
              .add(ExpertReview.fromSnapshot(snapshot.data()));
        } else {
          _reviewController.sink.addError(_notFoundError);
          _reviewController.sink.add(ExpertReview.empty());
        }
      });
    }
  }
}
