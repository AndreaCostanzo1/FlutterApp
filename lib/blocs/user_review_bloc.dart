import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_beertastic/model/beer.dart';
import 'package:flutter_beertastic/model/review.dart';
import 'package:flutter_beertastic/model/user.dart';
import 'package:synchronized/synchronized.dart';

class UserReviewBloc {
  StreamController<Review> _userReviewStreamController = StreamController();

  final List<StreamSubscription> _subscriptions = List();

  final Lock _lock = Lock();

  Stream<Review> get reviewStream => _userReviewStreamController.stream;

  void dispose() {
    _userReviewStreamController.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }

  void retrieveReview(Beer beer) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    DocumentReference beerRef =
        Firestore.instance.collection('beers').document(beer.id);
    _subscriptions.add(beerRef
        .collection('reviews')
        .document(fUser.uid)
        .snapshots()
        .listen((reviewSnap) {
      if (reviewSnap.data != null) {
        _retrieveUserAndNotifyReview(reviewSnap);
      } else {
        //notify no reviews for this beer
        _userReviewStreamController.sink.add(Review.empty());
      }
    }));
  }

  void createReview(Beer beer, String comment, double rate) async {
    //clear stream
    _userReviewStreamController.sink.add(null);
    //creation process
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    DocumentReference userRef =
        Firestore.instance.collection('users').document(fUser.uid);
    DocumentReference beerRef =
        Firestore.instance.collection('beers').document(beer.id);
    await _updateReviewsCount(beerRef, rate, false);
    beerRef.collection('reviews').document(fUser.uid).setData({
      'user': userRef,
      'date': DateTime.now(),
      'rate': rate,
      'comment': comment ?? ''
    });
  }

  void deleteReview(Beer beer, Review review) async {
    //clear stream
    _userReviewStreamController.sink.add(null);
    //creation process
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    DocumentReference beerRef =
        Firestore.instance.collection('beers').document(beer.id);
    await _updateReviewsCount(beerRef, review.rate.toDouble(), true);
    beerRef.collection('reviews').document(fUser.uid).delete();
  }

  void _retrieveUserAndNotifyReview(DocumentSnapshot reviewSnap) {
    DocumentReference userRef = reviewSnap['user'];
    userRef.get().then((userSnap) {
      Map<String, dynamic> reviewCompleteData = Map();
      reviewCompleteData.addAll(reviewSnap.data);
      reviewCompleteData.update(
          'user', (value) => User.fromSnapshot(userSnap.data));
      _userReviewStreamController.sink
          .add(Review.fromSnapshot(reviewCompleteData));
    });
  }

  Future<void> _updateReviewsCount(
      DocumentReference beerRef, double rate, bool delete) async {
    await _lock.synchronized(() async{
      await Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot beerSnap = await transaction.get(beerRef);
        if(beerSnap!=null&&beerSnap.exists){
          Beer beer = Beer.fromSnapshot(beerSnap.data);
          Map<String, int> map = Map.from(beer.ratingsByRate
              .map((key, value) => MapEntry(key.toString(), value)));
          map.update(rate.toInt().toString(),
                  (value) => delete ? value - 1 : value + 1);
          int newTotalRatings =
          delete ? beer.totalRatings - 1 : beer.totalRatings + 1;
          double averageRate = 0;
          if (newTotalRatings != 0) {
            map.entries.forEach(
                    (entry) => averageRate += int.parse(entry.key) * entry.value);
            averageRate = (averageRate / newTotalRatings * 10).round() / 10;
          }
          await transaction.update(beerRef, {
            'ratings_by_rate': map,
            'total_ratings': newTotalRatings,
            'rating': averageRate
          });
        }
      }).timeout(Duration(minutes: 1));
    });
    return null;
  }
}
