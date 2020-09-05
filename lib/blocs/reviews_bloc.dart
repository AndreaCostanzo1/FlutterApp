import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_beertastic/blocs/utilities/review_data_converter.dart';
import 'package:flutter_beertastic/model/review.dart';
import 'package:synchronized/synchronized.dart';

class ReviewsBloc {
  final List<Review> _reviews = List();

  DocumentSnapshot _lastDocument;

  static const int _queryLimit = 5;

  final FirebaseAuth _firebaseAuth;

  final FirebaseFirestore _firestore;

  int pid = 0;

  final Lock _lock = Lock();

  final StreamController<List<Review>> _reviewStreamController =
      StreamController.broadcast();

  final StreamController<bool> _availableDocumentsController =
      StreamController();

  ReviewsBloc():this._firestore=FirebaseFirestore.instance, this._firebaseAuth=FirebaseAuth.instance;

  ReviewsBloc.testConstructor(FirebaseAuth auth, FirebaseFirestore firestore):
      this._firebaseAuth= auth,this._firestore=firestore;

  Stream<List<Review>> get reviewsStream => _reviewStreamController.stream;

  Stream<bool> get availableDocumentsStream =>
      _availableDocumentsController.stream;

  static get queryLimit =>_queryLimit;

  void dispose() {
    _reviewStreamController.close();
    _availableDocumentsController.close();
  }

  void retrieveAllReviews(String beerId) async {
    int localPid;
    _lock.synchronized(() {
      _availableDocumentsController.sink.add(true);
      localPid = ++pid;
    });
    QuerySnapshot query = await _firestore
        .collection('beers')
        .doc(beerId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .limit(_queryLimit)
        .get();
    if (query.docs.length > 0) {
      _updateStream(query, localPid);
    } else {
      _lock.synchronized(() {
        _lastDocument = null;
        _reviews.clear();
        _reviewStreamController.sink.add(_reviews);
        _availableDocumentsController.sink.add(false);
      });
    }
  }

  Future<void> retrieveReviewsWithVote(String beerId, int vote) async {
    int localPid;
    _lock.synchronized(() {
      _availableDocumentsController.sink.add(true);
      localPid = ++pid;
    });
    QuerySnapshot query = await _firestore
        .collection('beers')
        .doc(beerId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .where('rate', isEqualTo: vote)
        .limit(_queryLimit)
        .get();
    if (query.docs.length > 0) {
      _updateStream(query, localPid);
    } else {
      _lock.synchronized(() {
        _lastDocument = null;
        _reviews.clear();
        _reviewStreamController.sink.add(_reviews);
        _availableDocumentsController.sink.add(false);
      });
    }
    return null;
  }

  void _updateStream(QuerySnapshot query, int localPid) {
    int i = 0;
    List<Review> localReviews = List();
    query.docs.forEach((reviewSnap) async {
      User fUser= _firebaseAuth.currentUser;
      DocumentReference userReference = reviewSnap.data()['user'];
      Map<String, dynamic> reviewCompleteData = await _generateReviewData(userReference,reviewSnap);
      _lock.synchronized(() {
        if(fUser.uid!=userReference.id)localReviews.add(Review.fromSnapshot(reviewCompleteData));
        i++;
        if (i >= query.docs.length &&
            !_reviewStreamController.isClosed &&
            pid == localPid) {
          _lastDocument = query.docs.last;
          _reviews.clear();
          localReviews.sort((review1,review2)=>review1.date.isBefore(review2.date)?1:-1);
          _reviews.addAll(localReviews);
          _reviewStreamController.sink.add(_reviews);
          if (i < _queryLimit) _availableDocumentsController.sink.add(false);
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

  Future<void> retrieveMoreReviews(String beerId) async {
    bool newDocumentsAvailable;
    int localPid;
    _lock.synchronized(() {
      localPid = ++pid;
      //if _reviews.length%limit=0 means that in the last query call i retrieved
      //a number of documents equal to the limit. If I would retrieved less documents
      //the result would have been != 0.
      //if _lastDocument==null in the last query the length was equal to 0
      newDocumentsAvailable =
          (_lastDocument != null && _reviews.length % _queryLimit == 0);
      if (!newDocumentsAvailable &&
          localPid == pid &&
          !_reviewStreamController.isClosed) {
        _availableDocumentsController.sink.add(false);
        _reviewStreamController.sink.add(_reviews);
      }
    });
    if (newDocumentsAvailable) {
      QuerySnapshot query = await _firestore
          .collection('beers')
          .doc(beerId)
          .collection('reviews')
          .orderBy('date', descending: true)
          .startAfterDocument(_lastDocument)
          .limit(_queryLimit)
          .get();
      if (query.docs.length > 0) {
        _updateStreamWithoutClearing(query, localPid);
      } else {
        _lock.synchronized(() {
          if (localPid == pid && !_reviewStreamController.isClosed) {
            _lastDocument = null;
            _reviewStreamController.sink.add(_reviews);
            _availableDocumentsController.sink.add(false);
          }
        });
      }
    }
    return null;
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
      (_lastDocument != null && _reviews.length % _queryLimit == 0);
      if (!newDocumentsAvailable &&
          localPid == pid &&
          !_reviewStreamController.isClosed) {
        _availableDocumentsController.sink.add(false);
        _reviewStreamController.sink.add(_reviews);
      }
    });
    if (newDocumentsAvailable) {
      QuerySnapshot query = await _firestore
          .collection('beers')
          .doc(beerId)
          .collection('reviews')
          .where('rate', isEqualTo: rate)
          .orderBy('date', descending: true)
          .startAfterDocument(_lastDocument)
          .limit(_queryLimit)
          .get();
      if (query.docs.length > 0) {
        _updateStreamWithoutClearing(query, localPid);
      } else {
        _lock.synchronized(() {
          if (localPid == pid && !_reviewStreamController.isClosed) {
            _lastDocument = null;
            _reviewStreamController.sink.add(_reviews);
            _availableDocumentsController.sink.add(false);
          }
        });
      }
    }
  }

  void _updateStreamWithoutClearing(QuerySnapshot query, int localPid) {
    int i = 0;
    List<Review> localReviews = List();
    query.docs.forEach((reviewSnap) async {
      User fUser= _firebaseAuth.currentUser;
      DocumentReference reference = reviewSnap.data()['user'];
      Map<String, dynamic> reviewCompleteData = await _generateReviewData(reference, reviewSnap);
      _lock.synchronized(() {
        if(fUser.uid!=reference.id)localReviews.add(Review.fromSnapshot(reviewCompleteData));
        i++;
        if (i >= query.docs.length &&
            !_reviewStreamController.isClosed &&
            pid == localPid) {
          _lastDocument = query.docs.last;
          localReviews.sort((review1,review2)=>review1.date.isBefore(review2.date)?1:-1);
          _reviews.addAll(localReviews);
          _reviewStreamController.sink.add(_reviews);
          if (i < _queryLimit) _availableDocumentsController.sink.add(false);
        }
      });
    });
  }



  Future<Map<String, dynamic>> _generateReviewData(DocumentReference userRef, DocumentSnapshot reviewSnap) async {
    DocumentSnapshot userSnapshot = await userRef.get();
    Map<String, dynamic> reviewCompleteData = ReviewDataConverter.convertSnapshot(reviewSnap.data(), userSnapshot.data());
    return reviewCompleteData;
  }
}
