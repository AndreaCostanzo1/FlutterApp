import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_beertastic/model/review.dart';

class ReviewsBloc {
  final List<Review> _reviews = List();

  DocumentSnapshot _lastDocument;

  final StreamController<List<Review>> _reviewStreamController =
      StreamController();

  Stream<List<Review>> get reviewsStream => _reviewStreamController.stream;

  void dispose() {
    _reviewStreamController.close();
  }

  void retrieveAllReviews(String beerId) async {
    QuerySnapshot query = await Firestore.instance
        .collection('beers')
        .document(beerId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .limit(20)
        .getDocuments();
    _reviews.clear();
    _lastDocument = query.documents.last;
    query.documents.forEach(
        (reviewSnap) => _reviews.add(Review.fromSnapshot(reviewSnap.data)));
    _reviews.forEach((element) => print(element.comment));
    _reviewStreamController.sink.add(_reviews);
  }

  void retrieveReviewsWithVote(String beerId, int vote) async {
    QuerySnapshot query = await Firestore.instance
        .collection('beers')
        .document(beerId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .where('rate', isEqualTo: vote)
        .limit(20)
        .getDocuments();
    _reviews.clear();
    _lastDocument = query.documents.last;
    query.documents.forEach(
        (reviewSnap) => _reviews.add(Review.fromSnapshot(reviewSnap.data)));
    _reviews.forEach((element) => print(element.comment));
    _reviewStreamController.sink.add(_reviews);
  }
}
