import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:flutter_beertastic/blocs/likes_bloc.dart';
import 'package:flutter_beertastic/model/beer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks/firebase_auth_mock.dart';

void main() {
  FirebaseAuthMock authMock = FirebaseAuthMock();
  final FirebaseFirestore firestoreMock = MockFirestoreInstance();
  final String beerMockID = 'duiqa98e21y1nquhdsau';
  final String beerMock2ndID = 'duiqa98e21y1nquhdsau';
  Timestamp timestamp = Timestamp.now();
  Map<String, dynamic> likeMock = {
    'beer': firestoreMock.collection('beers').doc(beerMockID),
    'date': timestamp,
  };

  Map<String, dynamic> like2ndMock = {
    'beer': firestoreMock.collection('beers').doc(beerMock2ndID),
    'date': timestamp,
  };

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
    'carbonation': 2.1,
    'searches': 0,
    'likes': 0,
  };

  Map<String, dynamic> beer2ndMock = {
    'id': beerMock2ndID,
    'name': '_name',
    'producer': '_producer',
    'rating': 4,
    'alcohol': 4,
    'temperature': 4,
    'beerImageUrl': '_beerImageUrl',
    'style': '_style',
    'color': '_color',
    'carbonation': 2.1,
    'searches': 0,
    'likes': 0,
  };

  group('verify if liked tests', () {
    test('verifyIfLiked case true', () async {
      //GIVEN: BEER WITH SAME ID IN FAVOURITES
      firestoreMock
          .collection('users')
          .doc(authMock.currentUser.uid)
          .collection('favourites')
          .doc(beerMockID)
          .set(likeMock);

      //WHEN: RETRIEVE FAVOURITES
      LikesBloc _bloc = LikesBloc.testConstructor(authMock, firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.verifyIfLiked(beerMockID);
      });
      Future<bool> likedBeerFuture = _bloc.likedBeerStream.first;
      completer.complete();
      bool liked = await likedBeerFuture;
      //ASSERT: BEER LIKED
      expect(liked, true);

      //FREE DB
      firestoreMock
          .collection('users')
          .doc(authMock.currentUser.uid)
          .collection('favourites')
          .doc(beerMockID);
    });

    test('verifyIfLiked case false with differen beer in db', () async {
      //GIVEN: BEER WITH DIFFERENT ID IN FAVOURITES
      firestoreMock
          .collection('users')
          .doc(authMock.currentUser.uid)
          .collection('favourites')
          .doc(beerMockID)
          .set(likeMock);

      //WHEN: RETRIEVE FAVOURITES
      LikesBloc _bloc = LikesBloc.testConstructor(authMock, firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.verifyIfLiked(beerMockID + 'aa');
      });
      Future<bool> likedBeerFuture = _bloc.likedBeerStream.first;
      completer.complete();
      bool liked = await likedBeerFuture;

      //ASSERT: BEER NOT LIKED
      expect(liked, false);

      //AFTER: FREE DB
      firestoreMock
          .collection('users')
          .doc(authMock.currentUser.uid)
          .collection('favourites')
          .doc(beerMockID);
    });

    test('verifyIfLiked case false with empty db', () async {
      //GIVEN: EMPTY DB

      //WHEN: RETRIEVE FAVOURITES
      LikesBloc _bloc = LikesBloc.testConstructor(authMock, firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.verifyIfLiked(beerMockID + 'aa');
      });
      Future<bool> likedBeerFuture = _bloc.likedBeerStream.first;
      completer.complete();
      bool liked = await likedBeerFuture;

      //ASSERT: BEER NOT LIKED
      expect(liked, false);

      //AFTER: FREE DB
      firestoreMock
          .collection('users')
          .doc(authMock.currentUser.uid)
          .collection('favourites')
          .doc(beerMockID);
    });
  });

  group('add to favourites tests', () {
    test('add to favourites', () async {
      //GIVEN: EMPTY DB

      //WHEN: THE USER ADDS A BEER TO FAVOURITES
      LikesBloc _bloc = LikesBloc.testConstructor(authMock, firestoreMock);
      await _bloc.addToFavourites(Beer.fromSnapshot(beerMock));

      //ASSERT: THE BEER IS IN DB
      Map<String, dynamic> map = (await firestoreMock
          .collection('users')
          .doc(authMock.currentUser.uid)
          .collection('favourites')
          .doc(beerMockID)
          .get())
          .data();
      expect(map['beer'], firestoreMock.collection('beers').doc(beerMockID));
    });
  });

  group('remove from favourites tests', () {
    test('remove from favourites', () async {
      //GIVEN: A FAVOURITE IN DB
      await firestoreMock
          .collection('users')
          .doc(authMock.currentUser.uid)
          .collection('favourites')
          .doc(beerMockID)
          .set(likeMock);
      Map<String, dynamic> map = (await firestoreMock
          .collection('users')
          .doc(authMock.currentUser.uid)
          .collection('favourites')
          .doc(beerMockID)
          .get())
          .data();
      //CHECK THAT THE BEER IS EFFECTIVELY IN THE DB
      expect(map['beer'], firestoreMock.collection('beers').doc(beerMockID));

      //WHEN: THE USER REMOVES A BEER FROM FAVOURITES
      LikesBloc _bloc = LikesBloc.testConstructor(authMock, firestoreMock);
      await _bloc.removeFromFavourites(Beer.fromSnapshot(beerMock));

      //ASSERT: THE BEER IS IN DB
      Map<String, dynamic> map2 = (await firestoreMock
          .collection('users')
          .doc(authMock.currentUser.uid)
          .collection('favourites')
          .doc(beerMockID)
          .get())
          .data();
      expect(map2, null);
    });
  });


  group('retrieve liked beer tests', () {
    test('no liked beer', () async {
      //GIVEN: NO LIKED BEERS

      //WHEN: USERS RETRIEVE LIKED BEERS
      LikesBloc _bloc = LikesBloc.testConstructor(authMock, firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveLikedBeers();
      });
      Future<List<Beer>> futureLikedBeerList = _bloc.likedBeerListStream.first;
      completer.complete();
      List<Beer> likedBeerList = await futureLikedBeerList;

      //ASSERT: NO LIKED BEERS IN LIST (LENGTH == 0)
      expect(likedBeerList.length, 0);
    });

    test('liked beers available', () async {
      //GIVEN: SOME LIKED BEERS
      //ADD LIKES TO DB
      await firestoreMock.collection('users')
          .doc(authMock.currentUser.uid)
          .collection('favourites')
          .doc(beerMockID).set(likeMock);
      await firestoreMock.collection('users')
          .doc(authMock.currentUser.uid)
          .collection('favourites')
          .doc(beerMock2ndID).set(like2ndMock);
      await firestoreMock.collection('beers')
          .doc(beerMockID).set(beerMock);
      await firestoreMock.collection('beers')
          .doc(beerMock2ndID).set(beer2ndMock);
      QuerySnapshot querySnapshot = await firestoreMock.collection('users')
          .doc(authMock.currentUser.uid)
          .collection('favourites').get();
      int likes = querySnapshot.docs.length;

      //WHEN: USERS RETRIEVE LIKED BEERS
      LikesBloc _bloc = LikesBloc.testConstructor(authMock, firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveLikedBeers();
      });
      Future<List<Beer>> futureLikedBeerList = _bloc.likedBeerListStream.first;
      completer.complete();
      List<Beer> likedBeerList = await futureLikedBeerList;

      //ASSERT: NO LIKED BEERS IN LIST (LENGTH == 0)
      expect(likedBeerList.length, likes);
      expect(likedBeerList.map((e) => e.id).contains(beerMockID), true);
      expect(likedBeerList.map((e) => e.id).contains(beerMock2ndID), true);
    });
  });
}
