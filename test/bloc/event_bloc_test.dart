import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_beertastic/blocs/event_bloc.dart';
import 'package:flutter_beertastic/model/city.dart';
import 'package:flutter_beertastic/model/event.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks/firebase_firestore_mock.dart';

void main() {
  GeoPoint geoPoint = GeoPoint(0, 0);
  Timestamp timestamp = Timestamp.fromDate(DateTime.now());
  String eventMockId = 'ashdh1283218xada';
  Map<String, dynamic> eventMock = Map.from({
    'id': eventMockId,
    'date': timestamp,
    'description': 'adsnsjanbsabdiasbdibqsadbqqwedqbxjxnnsaj',
    'title': 'asahda',
    'punch_line': '_punchLine',
    'android_fb_url': '_fbAndroidUrl',
    'fallback_fb_url': '_fbFallbackUrl',
    'instagram_url': '_instagramUrl',
    'coordinates': geoPoint,
    'reduced_title': 'adadadadas',
    'place_name': 'adadad',
  });

  Map<String, dynamic> cityMock = {
    'id': 'djiasjduhdq912ea',
    'geoHash': 'u0nd9hkpc',
    'latitude': 0.0,
    'longitude': 0.0,
    'name': 'random',
    'imageUrl': 'no_image',
  };

  group('retrieve beer in city tests', () {
    test('get only one beer', () async {
      List<Map<String,dynamic>> eventMocks = [eventMock];
      FirebaseFirestore firestoreMock =
          FirebaseFirestoreMock.fromResult(eventMocks);
      EventBloc _bloc = EventBloc.testConstructor(firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveEventsInCity(City.fromSnapshot(cityMock));
      });
      Future<List<Event>> futureEventList = _bloc.eventsStream.first;
      completer.complete();
      List<Event> eventList = await futureEventList;
      expect(eventList.length, eventMocks.length);
      expect(eventList.map((e) => e.id).contains(eventMockId), true);
      if (eventList.length < EventBloc.queryLimit) {
        expect(_bloc.noMoreEventsAvailable, true);
      }
    });

    test('get beers up to query limit', () async {
      List<Map<String, dynamic>> eventMocks = List();
      for (int i = 0; i < EventBloc.queryLimit; i++) eventMocks.add(eventMock);
      FirebaseFirestore firestoreMock =
          FirebaseFirestoreMock.fromResult(eventMocks);
      EventBloc _bloc = EventBloc.testConstructor(firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveEventsInCity(City.fromSnapshot(cityMock));
      });
      Future<List<Event>> futureEventList = _bloc.eventsStream.first;
      completer.complete();
      List<Event> eventList = await futureEventList;
      expect(eventList.length, EventBloc.queryLimit);
      expect(_bloc.noMoreEventsAvailable, false);
    });
  });


  group('retrieve more beer in city tests', () {
    test('get only one more beer', () async {

      //SETUP
      List<Map<String, dynamic>> eventMocks = List();
      for (int i = 0; i < EventBloc.queryLimit; i++) eventMocks.add(eventMock);
      FirebaseFirestoreMock firestoreMock =
      FirebaseFirestoreMock.fromResult(eventMocks);
      EventBloc _bloc = EventBloc.testConstructor(firestoreMock);
      Future<Null> setup;
      Completer<Null> setupCompleter = Completer();
      setup = setupCompleter.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await setup;
        _bloc.retrieveEventsInCity(City.fromSnapshot(cityMock));
      });
      Future<List<Event>> setupEventList = _bloc.eventsStream.first;
      setupCompleter.complete();
      await setupEventList;


      //TEST
      List<Map<String, dynamic>> eventMocks2 = List.from([eventMock]);
      firestoreMock.result = eventMocks2;
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveMoreEventsInCity(City.fromSnapshot(cityMock));
      });
      Future<List<Event>> futureEventList = _bloc.eventsStream.first;
      completer.complete();
      List<Event> eventList = await futureEventList;
      expect(eventList.length, EventBloc.queryLimit+ 1);
      if (eventMocks.length< EventBloc.queryLimit) {
        expect(_bloc.noMoreEventsAvailable, true);
      }
    });

    test('get more beers up to query limit', () async {
      //SETUP
      List<Map<String, dynamic>> eventMocks = List();
      for (int i = 0; i < EventBloc.queryLimit; i++) eventMocks.add(eventMock);
      FirebaseFirestoreMock firestoreMock =
      FirebaseFirestoreMock.fromResult(eventMocks);
      EventBloc _bloc = EventBloc.testConstructor(firestoreMock);
      Future<Null> setup;
      Completer<Null> setupCompleter = Completer();
      setup = setupCompleter.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await setup;
        _bloc.retrieveEventsInCity(City.fromSnapshot(cityMock));
      });
      Future<List<Event>> setupEventList = _bloc.eventsStream.first;
      setupCompleter.complete();
      await setupEventList;


      //TEST
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveMoreEventsInCity(City.fromSnapshot(cityMock));
      });
      Future<List<Event>> futureEventList = _bloc.eventsStream.first;
      completer.complete();
      List<Event> eventList = await futureEventList;
      expect(eventList.length, EventBloc.queryLimit*2);
      expect(_bloc.noMoreEventsAvailable, false);
    });
  });


  group('additional tests', () {
    test('dispose',() async{
      List<Map<String,dynamic>> eventMocks = [eventMock];
      FirebaseFirestore firestoreMock =
      FirebaseFirestoreMock.fromResult(eventMocks);
      EventBloc _bloc = EventBloc.testConstructor(firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.dispose();
      });


      Future<List<Event>> futureEventList = _bloc.eventsStream.last;
      _bloc.retrieveEventsInCity(City.fromSnapshot(cityMock));
      //WHEN: THE ARTICLE BLOC IS DISPOSED (AFTER COMPLETER.COMPLETE)
      completer.complete();


      //ASSERT: THE RESULT IS RETRIEVED CORRECTLY WITHOUT TIMEOUT ERRORS
      //NOTICE: calling last on a stream send the result only after the stream
      //is closed
      List<Event> eventList = await futureEventList.timeout(Duration(seconds: 10));
      expect(eventList.length, eventMocks.length);
      expect(eventList.map((e) => e.id).contains(eventMockId), true);
    });
  });
}
