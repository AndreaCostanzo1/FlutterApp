import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_beertastic/model/city.dart';
import 'package:flutter_beertastic/model/event.dart';

class EventBloc {
  StreamController<List<Event>> _eventsStreamController = StreamController();

  StreamController<Uint8List> _eventImageController =
      StreamController.broadcast();

  DocumentSnapshot _lastDocument;

  Stream<List<Event>> get eventsStream => _eventsStreamController.stream;

  Stream<Uint8List> get eventImageStream => _eventImageController.stream;

  void dispose() {
    _eventsStreamController.close();
    _eventImageController.close();
  }

  Future<void> retrieveEventsInCity(City city) async {
    DocumentReference cityRef =
        Firestore.instance.collection('cities').document(city.id);
    QuerySnapshot _eventsQuery = await cityRef
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: DateTime.now())
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
      _eventsStreamController.sink.add(events);
    } else {
      _eventsStreamController.sink.add(List());
    }
  }

  void retrieveEventImages(Event event) async {
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
}
