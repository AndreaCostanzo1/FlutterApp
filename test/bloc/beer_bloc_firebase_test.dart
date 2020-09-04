import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:flutter_beertastic/blocs/beer_bloc.dart';
import 'package:flutter_beertastic/model/beer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks/firebase_auth_mock.dart';
import 'mocks/firebase_functions_mock.dart';

void main(){
  final FirebaseAuthMock authMock = FirebaseAuthMock();
  final FirebaseFirestore firestoreMock = MockFirestoreInstance();
  final FirebaseFunctionsMock functionsMock = FirebaseFunctionsMock();
  final String beerMockID = 'duiqa98e21y1nquhdsau';
  Timestamp timestamp = Timestamp.now();

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

  Map<String,dynamic> searchMock = {
    'user': firestoreMock.collection('users').doc(authMock.currentUser.uid),
    'date': timestamp,
  };

  group('interactions with firestore', () {
    //THIS TEST CHECKS JUST IF QUERIES ARE OK. FUNCTIONS ARE NOT SIMULATED
    test('update searches', () {
      //GIVEN: A BEER IN DB and a recent research
      DocumentReference beerRef= firestoreMock.collection('beers').doc(beerMockID);
      beerRef.set(beerMock);
      beerRef.collection('searches').add(searchMock);
      //WHEN: UPDATE SEARCHES
      BeerBloc _bloc = BeerBloc.testConstructor(firestoreMock,authMock,functionsMock);
      _bloc.updateSearches(beerMockID);

      //ASSERT NO EXCEPTION
    });
    //TODO: When the plugin is working add tests to add and remove fav.
//    test('add to favourites', () async {
//      //GIVEN: A BEER IN DB
//      firestoreMock.collection('beers').doc(beerMockID).set(beerMock);
//
//      //WHEN: THE USER ADDS A BEER TO FAVOURITES
//      BeerBloc _bloc = BeerBloc.testConstructor(firestoreMock,authMock);
//      await _bloc.addToFavourites(Beer.fromSnapshot(beerMock));
//
//      //ASSERT: THE USER IS REGISTERED IN BEER FAV
//      Map<String, dynamic> map = (await firestoreMock
//          .collection('beers')
//          .doc(beerMockID)
//          .collection('favourites')
//          .doc(authMock.currentUser.uid)
//          .get())
//          .data();
//      expect(map['user'], firestoreMock.collection('users').doc(authMock.currentUser.uid));
//    });
  });
}