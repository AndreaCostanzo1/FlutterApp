import 'package:cloud_firestore/cloud_firestore.dart';

class CityDataConverter{

  static Map<String, dynamic> convertSnapshot(Map<String, dynamic> data) {
    Map<String, dynamic> _snapshotToGenerate = Map();
    GeoPoint geoPoint = data['geo_point'];
    _snapshotToGenerate.addAll(data);
    _snapshotToGenerate.addEntries([
      MapEntry('latitude', geoPoint.latitude),
      MapEntry('longitude', geoPoint.longitude)
    ]);
    return _snapshotToGenerate;
  }
}