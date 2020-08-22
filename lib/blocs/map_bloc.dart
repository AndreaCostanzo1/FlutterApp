import 'dart:async';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_beertastic/blocs/utilities/city_data_converter.dart';
import 'package:flutter_beertastic/blocs/utilities/geo_data.dart';
import 'package:flutter_beertastic/blocs/utilities/geo_hash_computer.dart';
import 'package:flutter_beertastic/model/city.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapBloc {
  final StreamController<List<City>> _nearestCitiesController =
      StreamController();

  final StreamController<Uint8List> _cityImageController = StreamController();

  Stream<List<City>> get nearestCityStream => _nearestCitiesController.stream;

  Stream<Uint8List> get cityImageStream => _cityImageController.stream;

  void dispose() {
    _nearestCitiesController.close();
    _cityImageController.close();
  }

  void retrieveCityImage(City city) async {
    Uint8List image = await FirebaseStorage.instance
        .ref()
        .child(city.imageUrl)
        .getData(600000);
    _cityImageController.sink.add(image);
  }

  void retrieveNearestCities() async {
    if (await Permission.location.request().isGranted) {
      GeoData data = await _computeGeoData();
      List<double> areaSizes = GeoHashComputer.areaPrecisions
          .where((element) => element > GeoHashComputer.PRECISION_KM_5)
          .toList();
      areaSizes.sort();
      List<DocumentSnapshot> snapshots = List();
      //continue to increment radius until a city is found
      for (int i = 0; i < areaSizes.length && snapshots.length < 2; i++) {
        snapshots = await _retrieveCitiesInArea(data, areaSizes[i]);
      }
      List<City> cities = List();
      if (snapshots.length > 0) {
        //case some cities found nearby
        cities.addAll(_getCityOrderedByVicinity(data, snapshots));
      } else {
        //no city nearby, select randomly
        FirebaseFirestore.instance.collection('cities').limit(5).get().then(
            (query) => query.docs.forEach((citySnap) => cities.add(
                City.fromSnapshot(
                    CityDataConverter.convertSnapshot(citySnap.data())))));
      }
      _nearestCitiesController.sink.add(cities);
    }
  }

  void setDefaultCity(User user) async {
    DocumentReference milanRef =
        FirebaseFirestore.instance.collection('city').doc('Milan');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'city': milanRef});
    _updateCityToNearestIfLocationPermissionGranted(user);
  }

  void _updateCityToNearestIfLocationPermissionGranted(User user) async {
    if (await Permission.location.request().isGranted) {
      GeoData data = await _computeGeoData();
      List<double> areaSizes = GeoHashComputer.areaPrecisions
          .where((element) => element > GeoHashComputer.PRECISION_KM_5)
          .toList();
      areaSizes.sort();
      List<DocumentSnapshot> snapshots = List();
      //continue to increment radius until a city is found
      for (int i = 0; i < areaSizes.length && snapshots.length == 0; i++) {
        snapshots = await _retrieveCitiesInArea(data, areaSizes[i]);
      }
      if (snapshots.length > 0) {
        DocumentSnapshot nearestCitySnap =
            _getNearestCitySnapshot(data, snapshots);
        DocumentReference nearestCityRef = FirebaseFirestore.instance
            .collection('cities')
            .doc(nearestCitySnap.id);
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'city': nearestCityRef});
      }
    }
  }

  Future<GeoData> _computeGeoData() async {
    Position position = await Geolocator().getCurrentPosition();
    return GeoData(position.latitude, position.longitude);
  }

  Future<QuerySnapshot> _queryZone(String zoneHash) {
    return FirebaseFirestore.instance
        .collection('cities')
        .where('geo_hash', isGreaterThanOrEqualTo: zoneHash)
        .where('geo_hash', isLessThan: zoneHash + '~')
        .get();
  }

  Future<List<DocumentSnapshot>> _retrieveCitiesInArea(
      GeoData center, double areaRadius) async {
    int precision = GeoHashComputer.setPrecision(areaRadius);
    String centerHash = center.hash.substring(0, precision);
    List<String> area = GeoData.neighborsOf(hash: centerHash)..add(centerHash);
    FutureGroup<QuerySnapshot> queries = FutureGroup();
    area.forEach((areaHash) => queries.add(_queryZone(areaHash)));
    queries.close();
    return (await queries.future)
        .map((e) => e.docs)
        .toList()
        .expand((element) => element)
        .toList();
  }

  DocumentSnapshot _getNearestCitySnapshot(
      GeoData startingPoint, List<DocumentSnapshot> snapshots) {
    Map<DocumentSnapshot, double> _citiesByDistance = Map();
    snapshots.forEach((citySnap) {
      GeoPoint geoPoint = citySnap.data()['geo_point'];
      _citiesByDistance.putIfAbsent(
          citySnap,
          () => startingPoint.distance(
              lat: geoPoint.latitude, lng: geoPoint.longitude));
    });
    List<double> distances = _citiesByDistance.values.toList();
    distances.sort();
    return _citiesByDistance.keys
        .firstWhere((key) => _citiesByDistance[key] == distances[0]);
  }

  List<City> _getCityOrderedByVicinity(
      GeoData startingPoint, List<DocumentSnapshot> snapshots) {
    Map<DocumentSnapshot, double> _citiesByDistance = Map();
    snapshots.forEach((citySnap) {
      GeoPoint geoPoint = citySnap.data()['geo_point'];
      _citiesByDistance.putIfAbsent(
          citySnap,
          () => startingPoint.distance(
              lat: geoPoint.latitude, lng: geoPoint.longitude));
    });
    List<double> distances = _citiesByDistance.values.toList();
    distances.sort();
    List<City> cities = List();
    distances.forEach((distance) {
      DocumentSnapshot snapshot = _citiesByDistance.keys
          .firstWhere((key) => _citiesByDistance[key] == distance);
      _citiesByDistance.remove(snapshot);
      cities.add(City.fromSnapshot(
          CityDataConverter.convertSnapshot(snapshot.data())));
    });
    return cities;
  }
}
