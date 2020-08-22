import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_beertastic/model/city.dart';
import 'package:flutter_beertastic/model/event.dart';
import 'package:synchronized/synchronized.dart';

class EventBloc {
  EventBloc() {
    _downloadedEvents = 0;
    _noMoreEventsAvailable = false;
  }

  StreamController<List<Event>> _eventsStreamController = StreamController();

  StreamController<Uint8List> _eventImageController =
      StreamController.broadcast();


  List<Event> _events=List();

  DocumentSnapshot _lastDocument;

  int _downloadedEvents;

  Lock _lock=Lock();

  bool _noMoreEventsAvailable;

  Stream<List<Event>> get eventsStream => _eventsStreamController.stream;

  Stream<Uint8List> get eventImageStream => _eventImageController.stream;

  int get downloadedEvents => _downloadedEvents;

  bool get noMoreEventsAvailable => _noMoreEventsAvailable;

  void dispose() {
    _eventsStreamController.close();
    _eventImageController.close();
  }

  Future<void> retrieveEventsInCity(City city) async {
    _noMoreEventsAvailable = false;
    DocumentReference cityRef =
        Firestore.instance.collection('cities').document(city.id);
    QuerySnapshot _eventsQuery = await cityRef
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('date')
        .limit(10)
        .getDocuments();
    if (_eventsQuery.documents.length > 0) {
      _lastDocument = _eventsQuery.documents.last;
      List<Event> events = List();
      _eventsQuery.documents.forEach((eventSnap) {
        Map<String, dynamic> eventData = Map.from(eventSnap.data);
        GeoPoint geoPoint = eventSnap.data['coordinates'];
        Timestamp timestamp = eventSnap.data['date'];
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
   await _lock.synchronized(() => _eventsStreamController.sink.add(_events));
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
    if (_lastDocument != null) {
      DocumentReference cityRef =
          Firestore.instance.collection('cities').document(city.id);
      QuerySnapshot _eventsQuery = await cityRef
          .collection('events')
          .where('date', isGreaterThanOrEqualTo: DateTime.now())
          .orderBy('date')
          .startAfterDocument(_lastDocument)
          .limit(10)
          .getDocuments();
      if (_eventsQuery.documents.length > 0) {
        _lastDocument = _eventsQuery.documents.last;
        List<Event> events = List();
        _eventsQuery.documents.forEach((eventSnap) {
          Map<String, dynamic> eventData = Map.from(eventSnap.data);
          GeoPoint geoPoint = eventSnap.data['coordinates'];
          Timestamp timestamp = eventSnap.data['date'];
          eventData.addAll({
            'latitude': geoPoint.latitude,
            'longitude': geoPoint.longitude,
            'date': timestamp.toDate()
          });
          events.add(Event.fromSnapshot(eventData));
        });
        _downloadedEvents = _downloadedEvents + events.length;
        await _lock.synchronized(() => _events.addAll(events));
      } else {
        _noMoreEventsAvailable = true;
      }
      await _lock.synchronized(() => _eventsStreamController.sink.add(_events));
    }
  }
}
