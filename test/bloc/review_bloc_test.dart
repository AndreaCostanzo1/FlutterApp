import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:flutter_beertastic/blocs/reviews_bloc.dart';
import 'package:flutter_beertastic/model/review.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks/firebase_auth_mock.dart';

void main() {
  final FirebaseAuthMock authMock = FirebaseAuthMock();
  final FirebaseFirestore firestoreMock = MockFirestoreInstance();
  final String reviewMockID = 'ahuah8218usjnsau';
  final String userMockUID = 'adajhuqhe71237123';
  final String beerMockID='adhquwe81one12q09';
  Timestamp timestamp = Timestamp.fromDate(DateTime.now());
  Map<String, dynamic> userMock = Map.from({
    'id': userMockUID,
    'profile_image_path': 'mock_path',
    'nickname': 'doesnt_matter',
    'email': 'random@random.it',
  });

  Map<String, dynamic> reviewMock = {
    'id': reviewMockID,
    'comment': 'Mock comment',
    'date': timestamp,
    'rate': 4,
    'user': firestoreMock.collection('users').doc(userMockUID),
  };

  Map<String, dynamic> userMock2 = Map.from({
    'id': authMock.currentUser.uid,
    'profile_image_path': 'mock_path',
    'nickname': 'doesnt_matter',
    'email': authMock.currentUser.email,
  });

  Map<String, dynamic> reviewMock2 = {
    'id': reviewMockID,
    'comment': 'Mock comment',
    'date': timestamp,
    'rate': 4,
    'user': firestoreMock.collection('users').doc(userMock2['id']),
  };


  group('', () {
    test('retrieve reviews', () async {
      //SETUP DB
      await firestoreMock.collection('users').doc(userMockUID).set(userMock);
      await firestoreMock.collection('users').doc(authMock.currentUser.uid).set(userMock2);
      await firestoreMock.collection('beers').doc(beerMockID).set({'id': beerMockID});
      await firestoreMock.collection('beers').doc(beerMockID).collection('reviews').doc(userMockUID).set(reviewMock);
      await firestoreMock.collection('beers').doc(beerMockID).collection('reviews').doc(authMock.currentUser.uid).set(reviewMock2);

      //START TEST
      ReviewsBloc _bloc = ReviewsBloc.testConstructor(authMock,firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveAllReviews(beerMockID);
      });
      Future<List<Review>> futureEventList = _bloc.reviewsStream.first;
      completer.complete();
      List<Review> reviewList = await futureEventList;
      List<String> reviewIDsList = reviewList.map((e) => e.id).toList();
      expect(reviewIDsList.contains(reviewMockID), true);
    });
  });
}
