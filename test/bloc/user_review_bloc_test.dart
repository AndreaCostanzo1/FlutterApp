import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:flutter_beertastic/blocs/user_review_bloc.dart';
import 'package:flutter_beertastic/model/beer.dart';
import 'package:flutter_beertastic/model/review.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks/firebase_auth_mock.dart';

void main() {
  final FirebaseAuthMock authMock = FirebaseAuthMock();
  final FirebaseFirestore firestoreMock = MockFirestoreInstance();
  String beerMockID = '113213131231231asdasf';
  Map<String, dynamic> beerMock = {
    'id': beerMockID,
    'name': '_name',
    'producer': '_producer',
    'rating': 4,
    'alcohol': 4,
    'temperature': 4,
    'beerImageUrl': '_beerImageUrl',
    'style': '_style',
    'color': '_color',
    'rate':0.0,
    'ratings_by_rate': {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0},
    'total_ratings':0,
    'carbonation': 2.1,
    'searches': 0,
    'likes': 0,
  };

  final Map<String, dynamic> mockUser = {
    'id': authMock.currentUser.uid,
    'profile_image_path': 'not relevant',
    'nickname': 'nick',
    'email': authMock.currentUser.uid,
  };

  Timestamp timestamp = Timestamp.now();

  Map<String, dynamic> reviewMock = {
    'user': firestoreMock.collection('users').doc(authMock.currentUser.uid),
    'date': timestamp,
    'rate': 4,
    'comment': 'not important'
  };

  group('retrieve review tests', () {
    test('review available', () async {
      //GIVEN A BEER WITH REVIEWS FROM THE USER
      await firestoreMock
          .collection('users')
          .doc(authMock.currentUser.uid)
          .set(mockUser);
      DocumentReference beerRef =
          firestoreMock.collection('beers').doc(beerMockID);
      await beerRef.set(beerMock);
      await beerRef
          .collection('reviews')
          .doc(authMock.currentUser.uid)
          .set(reviewMock);
      Beer mockBeerInstance = Beer.fromSnapshot(beerMock);

      //WHEN: RETRIEVE REVIEW
      UserReviewBloc reviewBloc =
          UserReviewBloc.testConstructor(authMock, firestoreMock);
      Future<Review> futureReview = reviewBloc.reviewStream.first;
      reviewBloc.retrieveReview(mockBeerInstance);
      Review review = await futureReview;
      //ASSERT REVIEW MATCH AND NOT EMPTY
      expect(Review.isEmpty(review), false);
      expect(review.id, authMock.currentUser.uid);

      //AFTER CLEAR DB
      await beerRef.delete();
      await firestoreMock
          .collection('users')
          .doc(authMock.currentUser.uid)
          .delete();
      await beerRef
          .collection('reviews')
          .doc(authMock.currentUser.uid)
          .delete();
    });

    test('review not available', () async {
      //GIVEN A BEER WITHOUT REVIEWS FROM THE USER
      await firestoreMock
          .collection('users')
          .doc(authMock.currentUser.uid)
          .set(mockUser);
      DocumentReference beerRef =
          firestoreMock.collection('beers').doc(beerMockID);
      await beerRef.set(beerMock);
      Beer mockBeerInstance = Beer.fromSnapshot(beerMock);

      //WHEN: RETRIEVE REVIEW
      UserReviewBloc reviewBloc =
          UserReviewBloc.testConstructor(authMock, firestoreMock);
      Future<Review> futureReview = reviewBloc.reviewStream.first;
      reviewBloc.retrieveReview(mockBeerInstance);
      Review review = await futureReview;

      //ASSERT REVIEW IS EMPTY
      expect(Review.isEmpty(review), true);

      //AFTER CLEAR DB
      await beerRef.delete();
      await firestoreMock
          .collection('users')
          .doc(authMock.currentUser.uid)
          .delete();
    });
  });

  test('dispose', () async {
    //GIVEN A BEER WITHOUT REVIEWS FROM THE USER
    await firestoreMock
        .collection('users')
        .doc(authMock.currentUser.uid)
        .set(mockUser);
    DocumentReference beerRef =
    firestoreMock.collection('beers').doc(beerMockID);
    await beerRef.set(beerMock);
    Beer mockBeerInstance = Beer.fromSnapshot(beerMock);

    //WHEN: DISPOSE
    Future<Null> run;
    Completer<Null> completer = Completer();
    run = completer.future;
    UserReviewBloc reviewBloc =
    UserReviewBloc.testConstructor(authMock, firestoreMock);
    Future.delayed(Duration(milliseconds: 100), () async {
      await run;
      reviewBloc.dispose();
    });
    Future<Review> futureReview = reviewBloc.reviewStream.last;
    reviewBloc.retrieveReview(mockBeerInstance);
    completer.complete();
    Review review = await futureReview.timeout(Duration(seconds: 10));

    //ASSERT REVIEW IS EMPTY
    expect(Review.isEmpty(review), true);

    //AFTER CLEAR DB
    await beerRef.delete();
    await firestoreMock
        .collection('users')
        .doc(authMock.currentUser.uid)
        .delete();
  });
}
