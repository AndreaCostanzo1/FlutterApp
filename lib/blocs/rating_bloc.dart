import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_beertastic/model/review.dart';
import 'package:flutter_beertastic/model/user.dart';
import 'package:synchronized/synchronized.dart';

class ReviewsBloc {
  final List<Review> _reviews = List();

  DocumentSnapshot _lastDocument;

  int pid = 0;

  final Lock _lock = Lock();

  final StreamController<List<Review>> _reviewStreamController =
      StreamController();

  Stream<List<Review>> get reviewsStream => _reviewStreamController.stream;

  void dispose() {
    _reviewStreamController.close();
  }

  void retrieveAllReviews(String beerId) async {
    int localPid;
    _lock.synchronized(() => localPid = ++pid);
    QuerySnapshot query = await Firestore.instance
        .collection('beers')
        .document(beerId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .limit(20)
        .getDocuments();
    if (query.documents.length > 0) {
      _updateStream(query, localPid);
    } else {
      _lock.synchronized(() {
        _lastDocument = null;
        _reviews.clear();
        _reviewStreamController.sink.add(_reviews);
      });
    }
  }

  void retrieveReviewsWithVote(String beerId, int vote) async {
    int localPid;
    _lock.synchronized(() => localPid = ++pid);
    QuerySnapshot query = await Firestore.instance
        .collection('beers')
        .document(beerId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .where('rate', isEqualTo: vote)
        .limit(20)
        .getDocuments();
    if (query.documents.length > 0) {
      _updateStream(query, localPid);
    } else {
      _lock.synchronized(() {
        _lastDocument = null;
        _reviews.clear();
        _reviewStreamController.sink.add(_reviews);
      });
    }
  }

  void _updateStream(QuerySnapshot query, int localPid) {
    int i = 0;
    List<Review> localReviews = List();
    query.documents.forEach((reviewSnap) async {
      i++;
      DocumentReference reference = reviewSnap.data['user'];
      DocumentSnapshot userSnapshot = await reference.get();
      Map<String, dynamic> reviewCompleteData = Map();
      reviewCompleteData.addAll(reviewSnap.data);
      reviewCompleteData.update(
          'user', (value) => User.fromSnapshot(userSnapshot.data));
      localReviews.add(Review.fromSnapshot(reviewCompleteData));
      _lock.synchronized(() {
        if (i >= query.documents.length &&
            !_reviewStreamController.isClosed &&
            pid == localPid) {
          _lastDocument = query.documents.last;
          _reviews.clear();
          _reviews.addAll(localReviews);
          _reviewStreamController.sink.add(_reviews);
        }
      });
    });
  }

  void clearStream() async {
    _lock.synchronized(() { if(!_reviewStreamController.isClosed)_reviewStreamController.sink.add(null);});
  }
}
