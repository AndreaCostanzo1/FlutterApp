import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_beertastic/blocs/utilities/geo_data.dart';
import 'package:flutter_beertastic/blocs/utilities/geo_hash_computer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapBloc {

  void dispose() {
    //TODO IMPLEMENT
  }

  void setDefaultCity(FirebaseUser user) async {
    DocumentReference milanRef =
        Firestore.instance.collection('city').document('Milan');
    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .updateData({'city': milanRef});
    _updateCityToNearestIfLocationPermissionGranted(user);
  }

  void _updateCityToNearestIfLocationPermissionGranted(
      FirebaseUser user) async {
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
        DocumentReference nearestCityRef = Firestore.instance.collection('cities').document(nearestCitySnap.documentID);
        Firestore.instance.collection('users').document(user.uid).updateData({'city':nearestCityRef});
      }
    }
  }

  Future<GeoData> _computeGeoData() async {
    Position position = await Geolocator().getCurrentPosition();
    return GeoData(position.latitude, position.longitude);
  }

  Future<QuerySnapshot> _queryZone(String zoneHash) {
    return Firestore.instance
        .collection('cities')
        .where('geo_hash', isGreaterThanOrEqualTo: zoneHash)
        .where('geo_hash', isLessThan: zoneHash + '~')
        .getDocuments();
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
        .map((e) => e.documents)
        .toList()
        .expand((element) => element)
        .toList();
  }

  DocumentSnapshot _getNearestCitySnapshot(
      GeoData startingPoint, List<DocumentSnapshot> snapshots) {
    Map<DocumentSnapshot, double> _citiesByDistance = Map();
    snapshots.forEach((citySnap) {
      GeoPoint geoPoint = citySnap['geo_point'];
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


}
