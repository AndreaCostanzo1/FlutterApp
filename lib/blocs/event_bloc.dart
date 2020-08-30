import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_beertastic/model/city.dart';
import 'package:flutter_beertastic/model/event.dart';
import 'package:synchronized/synchronized.dart';

class EventBloc {
  EventBloc() : this._firestore=FirebaseFirestore.instance{
    _downloadedEvents = 0;
    _noMoreEventsAvailable = false;
  }

  EventBloc.testConstructor(FirebaseFirestore firestore) : this._firestore=firestore{
    _downloadedEvents = 0;
    _noMoreEventsAvailable = false;
  }

  StreamController<List<Event>> _eventsStreamController = StreamController.broadcast();

  StreamController<Uint8List> _eventImageController =
      StreamController.broadcast();

  List<Event> _events = List();

  DocumentSnapshot _lastDocument;

  final FirebaseFirestore _firestore;

  static const queryLimit = 2;

  int _downloadedEvents;

  Lock _lock = Lock();

  bool _noMoreEventsAvailable;

  Stream<List<Event>> get eventsStream => _eventsStreamController.stream;

  Stream<Uint8List> get eventImageStream => _eventImageController.stream;

  int get downloadedEvents => _downloadedEvents;

  bool get noMoreEventsAvailable => _noMoreEventsAvailable;

  void dispose() async {
    await _lock.synchronized(() {
      _eventsStreamController.close();
      _eventImageController.close();
    });
  }

  Future<void> retrieveEventsInCity(City city) async {
    _noMoreEventsAvailable = false;
    DocumentReference cityRef =
        _firestore.collection('cities').doc(city.id);
    QuerySnapshot _eventsQuery = await cityRef
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('date')
        .limit(queryLimit)
        .get();
    if (_eventsQuery.docs.length > 0) {
      _lastDocument = _eventsQuery.docs.last;
      List<Event> events = List();
      _eventsQuery.docs.forEach((eventSnap) {
        Map<String, dynamic> eventData = Map.from(eventSnap.data());
        GeoPoint geoPoint = eventSnap.data()['coordinates'];
        Timestamp timestamp = eventSnap.data()['date'];
        eventData.addAll({
          'latitude': geoPoint.latitude,
          'longitude': geoPoint.longitude,
          'date': timestamp.toDate()
        });
        events.add(Event.fromSnapshot(eventData));
      });

      _downloadedEvents = events.length;
      await _lock.synchronized(() {
        _events.clear();
        _events.addAll(events);
      });
    } else {
      _downloadedEvents = 0;
    }
    await _lock.synchronized(() {
      if(_downloadedEvents<queryLimit) _noMoreEventsAvailable =true;
      if(!_eventsStreamController.isClosed) _eventsStreamController.sink.add(_events);
    });
  }

  void retrieveEventImage(Event event) async {
    try {
      Uint8List image = await FirebaseStorage.instance
          .ref()
          .child(event.imageUrl)
          .getData(700000);
      _eventImageController.sink.add(image);
    } catch (e) {
      print(e);
    }
  }

  void retrieveMoreEventsInCity(City city) async {
    DocumentSnapshot lastDoc;
    await _lock.synchronized(() {
      if(_lastDocument!=null){
        lastDoc=_lastDocument;
        _lastDocument=null;
      }
    });
    if (!_noMoreEventsAvailable&&lastDoc!=null) {
      DocumentReference cityRef =
          _firestore.collection('cities').doc(city.id);
      QuerySnapshot _eventsQuery = await cityRef
          .collection('events')
          .where('date', isGreaterThanOrEqualTo: DateTime.now())
          .orderBy('date')
          .startAfterDocument(lastDoc)
          .limit(queryLimit)
          .get();
      if (_eventsQuery.docs.length > 0) {
        _lastDocument = _eventsQuery.docs.last;
        List<Event> events = List();
        _eventsQuery.docs.forEach((eventSnap) {
          Map<String, dynamic> eventData = Map.from(eventSnap.data());
          GeoPoint geoPoint = eventSnap.data()['coordinates'];
          Timestamp timestamp = eventSnap.data()['date'];
          eventData.addAll({
            'latitude': geoPoint.latitude,
            'longitude': geoPoint.longitude,
            'date': timestamp.toDate()
          });
          events.add(Event.fromSnapshot(eventData));
        });
        _downloadedEvents = _downloadedEvents + events.length;
        await _lock.synchronized(() => _events.addAll(events));
      }
      await _lock.synchronized(() {
        if(_eventsQuery.docs.length<queryLimit)_noMoreEventsAvailable = true;
        if(!_eventsStreamController.isClosed) _eventsStreamController.sink.add(_events);
      });
    }
  }
}
