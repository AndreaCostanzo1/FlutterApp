import 'dart:async';

import 'package:flutter_beertastic/blocs/beer_bloc.dart';
import 'package:flutter_beertastic/model/beer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks/firebase_auth_mock.dart';
import 'mocks/firebase_firestore_mock.dart';

void main(){

  String beerMockID= '113213131231231asdasf';
  Map<String,dynamic> beerMock = {
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



  group('suggested beer queries', (){
    test('get only one beer',() async {
      FirebaseFirestoreMock firestoreMock = FirebaseFirestoreMock.fromResult([beerMock]);
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      BeerBloc _bloc =BeerBloc.testConstructor(firestoreMock,firebaseAuthMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveSuggestedBeers();
      });
      Future<List<Beer>> futureBeerList =_bloc.suggestedBeersStream.first;
      completer.complete();
      List<Beer> beerList = await futureBeerList;
      expect(beerList.length, 1);
      expect(beerList[0].id, beerMockID);
      if(beerList.length<BeerBloc.queryLimit){
        expect(_bloc.noMoreBeerAvailable,true);
      }
    });

    test('get beers up to limit',() async {
      List<Map<String,dynamic>> beers = List();
      for(int i =0;i<BeerBloc.queryLimit;i++) beers.add(Map.from(beerMock));
      FirebaseFirestoreMock firestoreMock = FirebaseFirestoreMock.fromResult(beers);
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      BeerBloc _bloc =BeerBloc.testConstructor(firestoreMock,firebaseAuthMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveSuggestedBeers();
      });
      Future<List<Beer>> futureBeerList =_bloc.suggestedBeersStream.first;
      completer.complete();
      List<Beer> beerList = await futureBeerList;
      expect(beerList.length, BeerBloc.queryLimit);
      expect(_bloc.noMoreBeerAvailable,false);
    });

    test('get only one more beer',() async {

      //SETUP
      List<Map<String,dynamic>> beers = List();
      for(int i =0;i<BeerBloc.queryLimit;i++) beers.add(Map.from(beerMock));
      FirebaseFirestoreMock firestoreMock = FirebaseFirestoreMock.fromResult(beers);
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      BeerBloc _bloc =BeerBloc.testConstructor(firestoreMock,firebaseAuthMock);
      Future<Null> setup;
      Completer<Null> setupCompleter = Completer();
      setup = setupCompleter.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await setup;
        _bloc.retrieveSuggestedBeers();
      });
      Future<List<Beer>> setupBeerList =_bloc.suggestedBeersStream.first;
      setupCompleter.complete();
      await setupBeerList;

      //BEGIN TEST
      firestoreMock.result=[beerMock];
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveMoreSuggestedBeers();
      });
      Future<List<Beer>> futureBeerList =_bloc.suggestedBeersStream.first;
      completer.complete();
      List<Beer> beerList = await futureBeerList;
      expect(beerList.length, BeerBloc.queryLimit+1);
      if(beerList.length<BeerBloc.queryLimit){
        expect(_bloc.noMoreBeerAvailable,true);
      }
    });

    test('get more beers up to limit',() async {

      List<Map<String,dynamic>> beers = List();
      for(int i =0;i<BeerBloc.queryLimit;i++) beers.add(Map.from(beerMock));
      FirebaseFirestoreMock firestoreMock = FirebaseFirestoreMock.fromResult(beers);
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      BeerBloc _bloc =BeerBloc.testConstructor(firestoreMock,firebaseAuthMock);
      Future<Null> setup;
      Completer<Null> setupCompleter = Completer();
      setup = setupCompleter.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await setup;
        _bloc.retrieveSuggestedBeers();
      });
      Future<List<Beer>> setupBeerList =_bloc.suggestedBeersStream.first;
      setupCompleter.complete();
      await setupBeerList;

      //BEGIN TEST
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveMoreSuggestedBeers();
      });
      Future<List<Beer>> futureBeerList =_bloc.suggestedBeersStream.first;
      completer.complete();
      List<Beer> beerList = await futureBeerList;
      expect(beerList.length, BeerBloc.queryLimit*2);
      expect(_bloc.noMoreBeerAvailable,false);
    });
  });

  group('search bar tests', (){
    test('search bar query',()async{
      FirebaseFirestoreMock firestoreMock = FirebaseFirestoreMock.fromResult([beerMock]);
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      BeerBloc _bloc =BeerBloc.testConstructor(firestoreMock,firebaseAuthMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveBeersWhenParameterIsLike('parameter', 'value');
      });
      Future<List<Beer>> futureBeerList =_bloc.queriedBeersStream.first;
      completer.complete();
      List<Beer> beerList = await futureBeerList;
      expect(beerList.length, 1);
      expect(beerList[0].id, beerMockID);
    });

    test('clear searches',()async{
      List<Map> beerMockList = [beerMock];
      FirebaseFirestoreMock firestoreMock = FirebaseFirestoreMock.fromResult(beerMockList);
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      BeerBloc _bloc =BeerBloc.testConstructor(firestoreMock,firebaseAuthMock);
      Future<Null> run;
      Future<Null> setup;
      Completer<Null> completer1 = Completer();
      Completer<Null> completer2 = Completer();
      //FILL THE BEER LIST
      run = completer1.future;
      Future<List<Beer>> futureBeerList1 =_bloc.queriedBeersStream.first;
      _bloc.retrieveBeersWhenParameterIsLike('parameter', 'value');
      completer1.complete();
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        setup=completer2.future;
        //CHECK SIZE IS >0
        expect((await futureBeerList1).length, beerMockList.length);
        _bloc.clearQueriedBeersStream();
        completer2.complete();
      });
      await setup;
      //CHECK THAT NOW THE LIST LENGTH IS 0
      Future<List<Beer>> futureBeerList2 =_bloc.queriedBeersStream.first;
      List<Beer> beerList = await futureBeerList2;
      expect(beerList.length, 0);
    });
  });

  group('single beer tests', (){
    test('retrieve single beer',() async {
      FirebaseFirestoreMock firestoreMock = FirebaseFirestoreMock.fromResult(beerMock);
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      BeerBloc _bloc =BeerBloc.testConstructor(firestoreMock,firebaseAuthMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveSingleBeer('random');
      });
      Future<Beer> futureBeer =_bloc.singleBeerStream.first;
      completer.complete();
      Beer beer = await futureBeer;
      expect(beer.id, beerMock['id']);
    });

    test('observe single beer',() async {
      FirebaseFirestoreMock firestoreMock = FirebaseFirestoreMock.fromResult(beerMock);
      FirebaseAuthMock firebaseAuthMock = FirebaseAuthMock();
      BeerBloc _bloc =BeerBloc.testConstructor(firestoreMock,firebaseAuthMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.observeSingleBeer('random');
      });
      Future<Beer> futureBeer =_bloc.singleBeerStream.first;
      completer.complete();
      Beer beer = await futureBeer;
      expect(beer.id, beerMock['id']);
    });
  });
}