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
  final String userMockUID = 'adajhuqhe71237123';
  final String beerMockID='adhquwe81one12q09';
  final int mockRate = 4;
  Timestamp timestamp = Timestamp.fromDate(DateTime.now());
  Map<String, dynamic> userMock = Map.from({
    'id': userMockUID,
    'profile_image_path': 'mock_path',
    'nickname': 'doesnt_matter',
    'email': 'random@random.it',
  });

  Map<String, dynamic> reviewMock = {
    'id': userMockUID,
    'comment': 'Mock comment',
    'date': timestamp,
    'rate': mockRate,
    'user': firestoreMock.collection('users').doc(userMockUID),
  };

  Map<String, dynamic> userMock2 = Map.from({
    'id': authMock.currentUser.uid,
    'profile_image_path': 'mock_path',
    'nickname': 'doesnt_matter',
    'email': authMock.currentUser.email,
  });

  Map<String, dynamic> reviewMock2 = {
    'id': authMock.currentUser.uid,
    'comment': 'Mock comment',
    'date': timestamp,
    'rate': 4,
    'user': firestoreMock.collection('users').doc(userMock2['id']),
  };


  group('reviews without grade filter', ()
  {
    test('retrieve one review', () async {
      //SETUP DB
      await firestoreMock.collection('users').doc(userMockUID).set(userMock);
      await firestoreMock.collection('users').doc(authMock.currentUser.uid).set(
          userMock2);
      await firestoreMock.collection('beers').doc(beerMockID).set(
          {'id': beerMockID});
      await firestoreMock.collection('beers').doc(beerMockID).collection(
          'reviews').doc(userMockUID).set(reviewMock);
      await firestoreMock.collection('beers').doc(beerMockID).collection(
          'reviews').doc(authMock.currentUser.uid).set(reviewMock2);

      //START TEST
      ReviewsBloc _bloc = ReviewsBloc.testConstructor(authMock, firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveAllReviews(beerMockID);
      });
      Future<List<Review>> futureEventList = _bloc.reviewsStream.first;
      Future<bool> documentsStillAvailableFuture = _bloc
          .availableDocumentsStream.last;
      completer.complete();
      List<Review> reviewList = await futureEventList;
      List<String> reviewIDsList = reviewList.map((e) => e.id).toList();
      expect(reviewIDsList.contains(userMockUID), true);
      QuerySnapshot query = await firestoreMock.collection('beers').doc(
          beerMockID).collection('reviews').get();
      if (query.docs.length < ReviewsBloc.queryLimit) {
        if (query.docs.map((e) => e.data()['user']).contains(
            firestoreMock.collection('users').doc(authMock.currentUser.uid))) {
          expect(reviewList.length, query.docs.length - 1);
        } else {
          expect(reviewList.length, query.docs.length);
        }
        //Call it otherwise last will never end and the await below will wait forever
        _bloc.dispose();
        bool docsAvailable = await documentsStillAvailableFuture;
        expect(docsAvailable, false);
      }

      //FREE FIRESTORE
      await firestoreMock.collection('users').doc(userMockUID).delete();
      await firestoreMock.collection('users')
          .doc(authMock.currentUser.uid)
          .delete();
      await firestoreMock.collection('beers').doc(beerMockID).delete();
      await firestoreMock.collection('beers').doc(beerMockID).collection(
          'reviews').doc(userMockUID).delete();
      await firestoreMock.collection('beers').doc(beerMockID).collection(
          'reviews').doc(authMock.currentUser.uid).delete();
    });


    test('retrieve reviews up to query limit', () async {
      //SETUP DB
      await firestoreMock.collection('users').doc(userMockUID).set(userMock);
      await firestoreMock.collection('beers').doc(beerMockID).set(
          {'id': beerMockID});
      for (int i = 0; i < ReviewsBloc.queryLimit; i++) {
        String tempUserID = userMockUID;
        Map<String, dynamic> tempReview = Map.from(reviewMock);
        if (i > 0) {
          tempUserID += i.toString();
          tempReview.update('id', (value) => tempUserID);
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).set(tempReview);
      }

      //START TEST
      ReviewsBloc _bloc = ReviewsBloc.testConstructor(authMock, firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveAllReviews(beerMockID);
      });
      Future<List<Review>> futureEventList = _bloc.reviewsStream.first;
      Future<bool> documentsStillAvailableFuture = _bloc
          .availableDocumentsStream.last;
      completer.complete();
      List<Review> reviewList = await futureEventList;
      List<String> reviewIDsList = reviewList.map((e) => e.id).toList();
      expect(reviewIDsList.contains(userMockUID), true);
      QuerySnapshot query = await firestoreMock.collection('beers').doc(
          beerMockID).collection('reviews').get();
      if (query.docs.length >= ReviewsBloc.queryLimit) {
        if (query.docs.map((e) => e.data()['user']).contains(
            firestoreMock.collection('users').doc(authMock.currentUser.uid))) {
          expect(reviewList.length, ReviewsBloc.queryLimit - 1);
        } else {
          expect(reviewList.length, ReviewsBloc.queryLimit);
        }
        //Call it otherwise last will never end and the await below will wait forever
        _bloc.dispose();
        bool docsAvailable = await documentsStillAvailableFuture;
        expect(docsAvailable, true);
      }

      //FREE FIRESTORE
      await firestoreMock.collection('users').doc(userMockUID).delete();
      await firestoreMock.collection('beers').doc(beerMockID).delete();
      for (int i = 0; i < ReviewsBloc.queryLimit; i++) {
        String tempUserID = userMockUID;
        if (i > 0) {
          tempUserID += i.toString();
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).delete();
      }
    });

    test('retrieve one more review', () async {
      //SETUP DB
      final int totalReviews = ReviewsBloc.queryLimit + 1;
      await firestoreMock.collection('users').doc(userMockUID).set(userMock);
      await firestoreMock.collection('beers').doc(beerMockID).set(
          {'id': beerMockID});
      for (int i = 0; i < totalReviews; i++) {
        String tempUserID = userMockUID;
        Map<String, dynamic> tempReview = Map.from(reviewMock);
        if (i > 0) {
          tempUserID += i.toString();
          tempReview.update('id', (value) => tempUserID);
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).set(tempReview);
      }

      //SETUP TEST
      ReviewsBloc _bloc = ReviewsBloc.testConstructor(authMock, firestoreMock);
      Future<Null> setup;
      Completer<Null> setupCompleter = Completer();
      setup = setupCompleter.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await setup;
        _bloc.retrieveAllReviews(beerMockID);
      });
      Future<List<Review>> setupEventList = _bloc.reviewsStream.first;
      setupCompleter.complete();
      List<Review> setupList = await setupEventList;
      QuerySnapshot setupQuery = await firestoreMock.collection('beers').doc(
          beerMockID)
          .collection('reviews')
          .orderBy('date', descending: true)
          .limit(ReviewsBloc.queryLimit)
          .get();
      if (setupQuery.docs.map((e) => e.data()['user']).contains(
          firestoreMock.collection('users').doc(authMock.currentUser.uid))) {
        expect(setupList.length, ReviewsBloc.queryLimit - 1);
      } else {
        expect(setupList.length, ReviewsBloc.queryLimit);
      }

      //START TEST
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        await _bloc.retrieveMoreReviews(beerMockID);
      });
      Future<List<Review>> futureEventList = _bloc.reviewsStream.first;
      Future<bool> documentsStillAvailableFuture = _bloc
          .availableDocumentsStream.last;
      completer.complete();
      List<Review> reviewList = await futureEventList;
      List<String> reviewIDsList = reviewList.map((e) => e.id).toList();
      expect(reviewIDsList.contains(userMockUID), true);
      QuerySnapshot query = await firestoreMock.collection('beers')
          .doc(beerMockID)
          .collection('reviews')
          .orderBy('date', descending: true)
          .startAfterDocument(setupQuery.docs.last)
          .limit(ReviewsBloc.queryLimit)
          .get();
      if (query.docs.map((e) => e.data()['user']).contains(
          firestoreMock.collection('users').doc(authMock.currentUser.uid))) {
        expect(
            reviewList.length, ReviewsBloc.queryLimit + query.docs.length - 1);
      } else {
        expect(reviewList.length, ReviewsBloc.queryLimit + query.docs.length);
      }
      //Call it otherwise last will never end and the await below will wait forever
      _bloc.dispose();
      bool docsAvailable = await documentsStillAvailableFuture;
      expect(docsAvailable, false);


      //FREE FIRESTORE
      await firestoreMock.collection('users').doc(userMockUID).delete();
      await firestoreMock.collection('beers').doc(beerMockID).delete();
      for (int i = 0; i < totalReviews; i++) {
        String tempUserID = userMockUID;
        if (i > 0) {
          tempUserID += i.toString();
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).delete();
      }
    });

    test('retrieve more reviews up to limit', () async {
      //SETUP DB
      final int totalReviews = ReviewsBloc.queryLimit *2;
      await firestoreMock.collection('users').doc(userMockUID).set(userMock);
      await firestoreMock.collection('beers').doc(beerMockID).set(
          {'id': beerMockID});
      for (int i = 0; i < totalReviews; i++) {
        String tempUserID = userMockUID;
        Map<String, dynamic> tempReview = Map.from(reviewMock);
        if (i > 0) {
          tempUserID += i.toString();
          tempReview.update('id', (value) => tempUserID);
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).set(tempReview);
      }

      //SETUP TEST
      ReviewsBloc _bloc = ReviewsBloc.testConstructor(authMock, firestoreMock);
      Future<Null> setup;
      Completer<Null> setupCompleter = Completer();
      setup = setupCompleter.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await setup;
        _bloc.retrieveAllReviews(beerMockID);
      });
      Future<List<Review>> setupEventList = _bloc.reviewsStream.first;
      setupCompleter.complete();
      List<Review> setupList = await setupEventList;
      QuerySnapshot setupQuery = await firestoreMock.collection('beers').doc(
          beerMockID)
          .collection('reviews')
          .orderBy('date', descending: true)
          .limit(ReviewsBloc.queryLimit)
          .get();
      if (setupQuery.docs.map((e) => e.data()['user']).contains(
          firestoreMock.collection('users').doc(authMock.currentUser.uid))) {
        expect(setupList.length, ReviewsBloc.queryLimit - 1);
      } else {
        expect(setupList.length, ReviewsBloc.queryLimit);
      }

      //START TEST
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        await _bloc.retrieveMoreReviews(beerMockID);
      });
      Future<List<Review>> futureEventList = _bloc.reviewsStream.first;
      Future<bool> documentsStillAvailableFuture = _bloc
          .availableDocumentsStream.last;
      completer.complete();
      List<Review> reviewList = await futureEventList;
      List<String> reviewIDsList = reviewList.map((e) => e.id).toList();
      expect(reviewIDsList.contains(userMockUID), true);
      QuerySnapshot query = await firestoreMock.collection('beers')
          .doc(beerMockID)
          .collection('reviews')
          .orderBy('date', descending: true)
          .startAfterDocument(setupQuery.docs.last)
          .limit(ReviewsBloc.queryLimit)
          .get();
      if (query.docs.map((e) => e.data()['user']).contains(
          firestoreMock.collection('users').doc(authMock.currentUser.uid))) {
        expect(
            reviewList.length, ReviewsBloc.queryLimit + query.docs.length - 1);
      } else {
        expect(reviewList.length, ReviewsBloc.queryLimit + query.docs.length);
      }
      //Call it otherwise last will never end and the await below will wait forever
      _bloc.dispose();
      bool docsAvailable = await documentsStillAvailableFuture;
      expect(docsAvailable, true);


      //FREE FIRESTORE
      await firestoreMock.collection('users').doc(userMockUID).delete();
      await firestoreMock.collection('beers').doc(beerMockID).delete();
      for (int i = 0; i < totalReviews; i++) {
        String tempUserID = userMockUID;
        if (i > 0) {
          tempUserID += i.toString();
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).delete();
      }
    });
  });


  //SECOND GROUP

  group('reviews with defined rate', ()
  {
    test('retrieve one review with defined rate', () async {
      //SETUP DB
      await firestoreMock.collection('users').doc(userMockUID).set(userMock);
      await firestoreMock.collection('users').doc(authMock.currentUser.uid).set(
          userMock2);
      await firestoreMock.collection('beers').doc(beerMockID).set(
          {'id': beerMockID});
      await firestoreMock.collection('beers').doc(beerMockID).collection(
          'reviews').doc(userMockUID).set(reviewMock);
      await firestoreMock.collection('beers').doc(beerMockID).collection(
          'reviews').doc(authMock.currentUser.uid).set(reviewMock2);

      //START TEST
      ReviewsBloc _bloc = ReviewsBloc.testConstructor(authMock, firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveReviewsWithVote(beerMockID,mockRate);
      });
      Future<List<Review>> futureEventList = _bloc.reviewsStream.first;
      Future<bool> documentsStillAvailableFuture = _bloc
          .availableDocumentsStream.last;
      completer.complete();
      List<Review> reviewList = await futureEventList;
      List<String> reviewIDsList = reviewList.map((e) => e.id).toList();
      expect(reviewIDsList.contains(userMockUID), true);
      QuerySnapshot query = await firestoreMock.collection('beers').doc(
          beerMockID).collection('reviews').where('rate', isEqualTo: mockRate).get();
      if (query.docs.length < ReviewsBloc.queryLimit) {
        if (query.docs.map((e) => e.data()['user']).contains(
            firestoreMock.collection('users').doc(authMock.currentUser.uid))) {
          expect(reviewList.length, query.docs.length - 1);
        } else {
          expect(reviewList.length, query.docs.length);
        }
        //Call it otherwise last will never end and the await below will wait forever
        _bloc.dispose();
        bool docsAvailable = await documentsStillAvailableFuture;
        expect(docsAvailable, false);
      }

      //FREE FIRESTORE
      await firestoreMock.collection('users').doc(userMockUID).delete();
      await firestoreMock.collection('users')
          .doc(authMock.currentUser.uid)
          .delete();
      await firestoreMock.collection('beers').doc(beerMockID).delete();
      await firestoreMock.collection('beers').doc(beerMockID).collection(
          'reviews').doc(userMockUID).delete();
      await firestoreMock.collection('beers').doc(beerMockID).collection(
          'reviews').doc(authMock.currentUser.uid).delete();
    });


    test('no reviews for defined rate', () async {
      //SETUP DB
      await firestoreMock.collection('users').doc(userMockUID).set(userMock);
      await firestoreMock.collection('beers').doc(beerMockID).set(
          {'id': beerMockID});
      for (int i = 0; i < ReviewsBloc.queryLimit; i++) {
        String tempUserID = userMockUID;
        Map<String, dynamic> tempReview = Map.from(reviewMock);
        if (i > 0) {
          tempUserID += i.toString();
          tempReview.update('id', (value) => tempUserID);
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).set(tempReview);
      }

      //START TEST
      ReviewsBloc _bloc = ReviewsBloc.testConstructor(authMock, firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveReviewsWithVote(beerMockID,mockRate-1);
      });
      Future<List<Review>> futureEventList = _bloc.reviewsStream.first;
      Future<bool> documentsStillAvailableFuture = _bloc
          .availableDocumentsStream.last;
      completer.complete();
      List<Review> reviewList = await futureEventList;
      expect(reviewList.length, 0);
      _bloc.dispose();
      bool docsAvailable = await documentsStillAvailableFuture;
      expect(docsAvailable, false);


      //FREE FIRESTORE
      await firestoreMock.collection('users').doc(userMockUID).delete();
      await firestoreMock.collection('beers').doc(beerMockID).delete();
      for (int i = 0; i < ReviewsBloc.queryLimit; i++) {
        String tempUserID = userMockUID;
        if (i > 0) {
          tempUserID += i.toString();
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).delete();
      }
    });

    test('retrieve reviews up to query limit with defined rate', () async {
      //SETUP DB
      await firestoreMock.collection('users').doc(userMockUID).set(userMock);
      await firestoreMock.collection('beers').doc(beerMockID).set(
          {'id': beerMockID});
      for (int i = 0; i < ReviewsBloc.queryLimit; i++) {
        String tempUserID = userMockUID;
        Map<String, dynamic> tempReview = Map.from(reviewMock);
        if (i > 0) {
          tempUserID += i.toString();
          tempReview.update('id', (value) => tempUserID);
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).set(tempReview);
      }

      //START TEST
      ReviewsBloc _bloc = ReviewsBloc.testConstructor(authMock, firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveReviewsWithVote(beerMockID,mockRate);
      });
      Future<List<Review>> futureEventList = _bloc.reviewsStream.first;
      Future<bool> documentsStillAvailableFuture = _bloc
          .availableDocumentsStream.last;
      completer.complete();
      List<Review> reviewList = await futureEventList;
      List<String> reviewIDsList = reviewList.map((e) => e.id).toList();
      expect(reviewIDsList.contains(userMockUID), true);
      QuerySnapshot query = await firestoreMock.collection('beers').doc(
          beerMockID).collection('reviews').where('rate', isEqualTo: mockRate).get();
      if (query.docs.length >= ReviewsBloc.queryLimit) {
        if (query.docs.map((e) => e.data()['user']).contains(
            firestoreMock.collection('users').doc(authMock.currentUser.uid))) {
          expect(reviewList.length, ReviewsBloc.queryLimit - 1);
        } else {
          expect(reviewList.length, ReviewsBloc.queryLimit);
        }
        //Call it otherwise last will never end and the await below will wait forever
        _bloc.dispose();
        bool docsAvailable = await documentsStillAvailableFuture;
        expect(docsAvailable, true);
      }

      //FREE FIRESTORE
      await firestoreMock.collection('users').doc(userMockUID).delete();
      await firestoreMock.collection('beers').doc(beerMockID).delete();
      for (int i = 0; i < ReviewsBloc.queryLimit; i++) {
        String tempUserID = userMockUID;
        if (i > 0) {
          tempUserID += i.toString();
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).delete();
      }
    });

    test('retrieve one more review with defined rate', () async {
      //SETUP DB
      final int totalReviews = ReviewsBloc.queryLimit + 1;
      await firestoreMock.collection('users').doc(userMockUID).set(userMock);
      await firestoreMock.collection('beers').doc(beerMockID).set(
          {'id': beerMockID});
      for (int i = 0; i < totalReviews; i++) {
        String tempUserID = userMockUID;
        Map<String, dynamic> tempReview = Map.from(reviewMock);
        if (i > 0) {
          tempUserID += i.toString();
          tempReview.update('id', (value) => tempUserID);
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).set(tempReview);
      }

      //SETUP TEST
      ReviewsBloc _bloc = ReviewsBloc.testConstructor(authMock, firestoreMock);
      Future<Null> setup;
      Completer<Null> setupCompleter = Completer();
      setup = setupCompleter.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await setup;
        _bloc.retrieveReviewsWithVote(beerMockID,mockRate);
      });
      Future<List<Review>> setupEventList = _bloc.reviewsStream.first;
      setupCompleter.complete();
      List<Review> setupList = await setupEventList;
      QuerySnapshot setupQuery = await firestoreMock.collection('beers').doc(
          beerMockID)
          .collection('reviews')
          .where('rate', isEqualTo: mockRate)
          .orderBy('date', descending: true)
          .limit(ReviewsBloc.queryLimit)
          .get();
      if (setupQuery.docs.map((e) => e.data()['user']).contains(
          firestoreMock.collection('users').doc(authMock.currentUser.uid))) {
        expect(setupList.length, ReviewsBloc.queryLimit - 1);
      } else {
        expect(setupList.length, ReviewsBloc.queryLimit);
      }

      //START TEST
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveMoreReviewsWithRate(mockRate,beerMockID);
      });
      Future<List<Review>> futureEventList = _bloc.reviewsStream.first;
      Future<bool> documentsStillAvailableFuture = _bloc
          .availableDocumentsStream.last;
      completer.complete();
      List<Review> reviewList = await futureEventList;
      List<String> reviewIDsList = reviewList.map((e) => e.id).toList();
      expect(reviewIDsList.contains(userMockUID), true);
      QuerySnapshot query = await firestoreMock.collection('beers')
          .doc(beerMockID)
          .collection('reviews')
          .where('rate', isEqualTo: mockRate)
          .orderBy('date', descending: true)
          .startAfterDocument(setupQuery.docs.last)
          .limit(ReviewsBloc.queryLimit)
          .get();
      if (query.docs.map((e) => e.data()['user']).contains(
          firestoreMock.collection('users').doc(authMock.currentUser.uid))) {
        expect(
            reviewList.length, ReviewsBloc.queryLimit + query.docs.length - 1);
      } else {
        expect(reviewList.length, ReviewsBloc.queryLimit + query.docs.length);
      }
      //Call it otherwise last will never end and the await below will wait forever
      _bloc.dispose();
      bool docsAvailable = await documentsStillAvailableFuture;
      expect(docsAvailable, false);


      //FREE FIRESTORE
      await firestoreMock.collection('users').doc(userMockUID).delete();
      await firestoreMock.collection('beers').doc(beerMockID).delete();
      for (int i = 0; i < totalReviews; i++) {
        String tempUserID = userMockUID;
        if (i > 0) {
          tempUserID += i.toString();
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).delete();
      }
    });



    test('retrieve more reviews up to limit with defined rate', () async {
      //SETUP DB
      final int totalReviews = ReviewsBloc.queryLimit *2;
      await firestoreMock.collection('users').doc(userMockUID).set(userMock);
      await firestoreMock.collection('beers').doc(beerMockID).set(
          {'id': beerMockID});
      for (int i = 0; i < totalReviews; i++) {
        String tempUserID = userMockUID;
        Map<String, dynamic> tempReview = Map.from(reviewMock);
        if (i > 0) {
          tempUserID += i.toString();
          tempReview.update('id', (value) => tempUserID);
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).set(tempReview);
      }

      //SETUP TEST
      ReviewsBloc _bloc = ReviewsBloc.testConstructor(authMock, firestoreMock);
      Future<Null> setup;
      Completer<Null> setupCompleter = Completer();
      setup = setupCompleter.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await setup;
        _bloc.retrieveReviewsWithVote(beerMockID,mockRate);
      });
      Future<List<Review>> setupEventList = _bloc.reviewsStream.first;
      setupCompleter.complete();
      List<Review> setupList = await setupEventList;
      QuerySnapshot setupQuery = await firestoreMock.collection('beers').doc(
          beerMockID)
          .collection('reviews')
          .where('rate', isEqualTo: mockRate)
          .orderBy('date', descending: true)
          .limit(ReviewsBloc.queryLimit)
          .get();
      if (setupQuery.docs.map((e) => e.data()['user']).contains(
          firestoreMock.collection('users').doc(authMock.currentUser.uid))) {
        expect(setupList.length, ReviewsBloc.queryLimit - 1);
      } else {
        expect(setupList.length, ReviewsBloc.queryLimit);
      }

      //START TEST
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveMoreReviewsWithRate(mockRate,beerMockID);
      });
      Future<List<Review>> futureEventList = _bloc.reviewsStream.first;
      Future<bool> documentsStillAvailableFuture = _bloc
          .availableDocumentsStream.last;
      completer.complete();
      List<Review> reviewList = await futureEventList;
      List<String> reviewIDsList = reviewList.map((e) => e.id).toList();
      expect(reviewIDsList.contains(userMockUID), true);
      QuerySnapshot query = await firestoreMock.collection('beers')
          .doc(beerMockID)
          .collection('reviews')
          .where('rate', isEqualTo: mockRate)
          .orderBy('date', descending: true)
          .startAfterDocument(setupQuery.docs.last)
          .limit(ReviewsBloc.queryLimit)
          .get();
      if (query.docs.map((e) => e.data()['user']).contains(
          firestoreMock.collection('users').doc(authMock.currentUser.uid))) {
        expect(
            reviewList.length, ReviewsBloc.queryLimit + query.docs.length - 1);
      } else {
        expect(reviewList.length, ReviewsBloc.queryLimit + query.docs.length);
      }
      //Call it otherwise last will never end and the await below will wait forever
      _bloc.dispose();
      bool docsAvailable = await documentsStillAvailableFuture;
      expect(docsAvailable, true);


      //FREE FIRESTORE
      await firestoreMock.collection('users').doc(userMockUID).delete();
      await firestoreMock.collection('beers').doc(beerMockID).delete();
      for (int i = 0; i < totalReviews; i++) {
        String tempUserID = userMockUID;
        if (i > 0) {
          tempUserID += i.toString();
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).delete();
      }
    });

    test('no more reviews with defined rate', () async {
      //SETUP DB
      final int totalReviews = ReviewsBloc.queryLimit *2;
      await firestoreMock.collection('users').doc(userMockUID).set(userMock);
      await firestoreMock.collection('beers').doc(beerMockID).set(
          {'id': beerMockID});
      for (int i = 0; i < totalReviews; i++) {
        String tempUserID = userMockUID;
        Map<String, dynamic> tempReview = Map.from(reviewMock);
        if (i > 0) {
          tempUserID += i.toString();
          tempReview.update('id', (value) => tempUserID);
        }
        if(i>=ReviewsBloc.queryLimit){
          tempReview.update('rate', (value) => value-1);
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).set(tempReview);
      }

      //SETUP TEST
      ReviewsBloc _bloc = ReviewsBloc.testConstructor(authMock, firestoreMock);
      Future<Null> setup;
      Completer<Null> setupCompleter = Completer();
      setup = setupCompleter.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await setup;
        _bloc.retrieveReviewsWithVote(beerMockID,mockRate);
      });
      Future<List<Review>> setupEventList = _bloc.reviewsStream.first;
      setupCompleter.complete();
      List<Review> setupList = await setupEventList;
      QuerySnapshot setupQuery = await firestoreMock.collection('beers').doc(
          beerMockID)
          .collection('reviews')
          .where('rate', isEqualTo: mockRate)
          .orderBy('date', descending: true)
          .limit(ReviewsBloc.queryLimit)
          .get();
      if (setupQuery.docs.map((e) => e.data()['user']).contains(
          firestoreMock.collection('users').doc(authMock.currentUser.uid))) {
        expect(setupList.length, ReviewsBloc.queryLimit - 1);
      } else {
        expect(setupList.length, ReviewsBloc.queryLimit);
      }

      //START TEST
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveMoreReviewsWithRate(mockRate,beerMockID);
      });
      Future<List<Review>> futureEventList = _bloc.reviewsStream.first;
      Future<bool> documentsStillAvailableFuture = _bloc
          .availableDocumentsStream.last;
      completer.complete();
      List<Review> reviewList = await futureEventList;
      List<String> reviewIDsList = reviewList.map((e) => e.id).toList();
      expect(reviewIDsList.contains(userMockUID), true);
      if (setupQuery.docs.map((e) => e.data()['user']).contains(
          firestoreMock.collection('users').doc(authMock.currentUser.uid))) {
        expect(reviewList.length, ReviewsBloc.queryLimit - 1);
      } else {
        expect(reviewList.length, ReviewsBloc.queryLimit);
      }
      //Call it otherwise last will never end and the await below will wait forever
      _bloc.dispose();
      bool docsAvailable = await documentsStillAvailableFuture;
      expect(docsAvailable, false);


      //FREE FIRESTORE
      await firestoreMock.collection('users').doc(userMockUID).delete();
      await firestoreMock.collection('beers').doc(beerMockID).delete();
      for (int i = 0; i < totalReviews; i++) {
        String tempUserID = userMockUID;
        if (i > 0) {
          tempUserID += i.toString();
        }
        await firestoreMock.collection('beers').doc(beerMockID).collection(
            'reviews').doc(tempUserID).delete();
      }
    });
  });
}
