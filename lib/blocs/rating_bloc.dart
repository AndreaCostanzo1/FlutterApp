import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_beertastic/model/review.dart';
import 'package:flutter_beertastic/model/user.dart';
import 'package:synchronized/synchronized.dart';

class ReviewsBloc {
  final List<Review> _reviews = List();

  DocumentSnapshot _lastDocument;

  final int limit = 5;

  int pid = 0;

  final Lock _lock = Lock();

  final StreamController<List<Review>> _reviewStreamController =
      StreamController.broadcast();

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
        .limit(limit)
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
        .limit(limit)
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

      DocumentReference reference = reviewSnap.data['user'];
      DocumentSnapshot userSnapshot = await reference.get();
      Map<String, dynamic> reviewCompleteData = Map();
      reviewCompleteData.addAll(reviewSnap.data);
      reviewCompleteData.update(
          'user', (value) => User.fromSnapshot(userSnapshot.data));
      _lock.synchronized(() {
      localReviews.add(Review.fromSnapshot(reviewCompleteData));
      i++;
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
    _lock.synchronized(() {
      if (!_reviewStreamController.isClosed)
        _reviewStreamController.sink.add(null);
    });
  }

  void retrieveMoreReviews(String beerId) async {

    bool newDocumentsAvailable;
    int localPid;
    _lock.synchronized(() {
      localPid = ++pid;
      //if _reviews.length%limit=0 means that in the last query call i retrieved
      //a number of documents equal to the limit. If I would retrieved less documents
      //the result would have been != 0.
      //if _lastDocument==null in the last query the length was equal to 0
      newDocumentsAvailable =
          (_lastDocument != null && _reviews.length % limit == 0);
      if(!newDocumentsAvailable&&localPid==pid&&!_reviewStreamController.isClosed)  _reviewStreamController.sink.add(_reviews);
    });
    if (newDocumentsAvailable) {
      QuerySnapshot query = await Firestore.instance
          .collection('beers')
          .document(beerId)
          .collection('reviews')
          .orderBy('date', descending: true)
          .limit(limit)
          .startAfterDocument(_lastDocument)
          .getDocuments();
      if (query.documents.length > 0) {
        _updateStreamWithoutClearing(query, localPid);
      } else {
        _lock.synchronized(() {
          if(localPid==pid&&!_reviewStreamController.isClosed){
            _lastDocument = null;
            _reviewStreamController.sink.add(_reviews);
          }
        });
      }
    }
  }

  void _updateStreamWithoutClearing(QuerySnapshot query, int localPid) {
    int i = 0;
    List<Review> localReviews = List();
    query.documents.forEach((reviewSnap) async {
      DocumentReference reference = reviewSnap.data['user'];
      DocumentSnapshot userSnapshot = await reference.get();
        Map<String, dynamic> reviewCompleteData = Map();
        reviewCompleteData.addAll(reviewSnap.data);
        reviewCompleteData.update(
            'user', (value) => User.fromSnapshot(userSnapshot.data));
      _lock.synchronized(() {
        localReviews.add(Review.fromSnapshot(reviewCompleteData));
        i++;
        if (i >= query.documents.length &&
            !_reviewStreamController.isClosed &&
            pid == localPid) {
          _lastDocument = query.documents.last;
          _reviews.addAll(localReviews);
          _reviewStreamController.sink.add(_reviews);
        }
      });
    });
  }

  void retrieveMoreReviewsWithRate(int rate, String beerId) async {
    bool newDocumentsAvailable;
    int localPid;
    _lock.synchronized(() {
      localPid = ++pid;

      //if _reviews.length%limit=0 means that in the last query call i retrieved
      //a number of documents equal to the limit. If I would retrieved less documents
      //the result would have been != 0.
      //if _lastDocument==null in the last query the length was equal to 0
      newDocumentsAvailable =
      (_lastDocument != null && _reviews.length % limit == 0);
      if(!newDocumentsAvailable&&localPid==pid&&!_reviewStreamController.isClosed)  _reviewStreamController.sink.add(_reviews);
    });
    if (newDocumentsAvailable) {
      QuerySnapshot query = await Firestore.instance
          .collection('beers')
          .document(beerId)
          .collection('reviews')
          .where('rate', isEqualTo: rate)
          .orderBy('date', descending: true)
          .limit(limit)
          .startAfterDocument(_lastDocument)
          .getDocuments();
      if (query.documents.length > 0) {
        _updateStreamWithoutClearing(query, localPid);
      } else {
        _lock.synchronized(() {
          if(localPid==pid&&!_reviewStreamController.isClosed){
            _lastDocument = null;
            _reviewStreamController.sink.add(_reviews);
          }
        });
      }
    }
  }
}
