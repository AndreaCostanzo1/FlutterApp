import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_beertastic/blocs/utilities/geo_hash_computer.dart';
import 'package:meta/meta.dart';

///NOTICE: This code is taken from
///https://github.com/DarshanGowda0/GeoFlutterFire
///Also in this case, for better understand what the class contains, I renamed it
///as GeoData (original name: GeoFirePoint)

class GeoData {
  static GeoHashComputer _gHComputer = GeoHashComputer();
  double _latitude, _longitude;
  String _hash;

  GeoData(this._latitude, this._longitude): this._hash = _gHComputer.encode(_latitude, _longitude, 9);

  /// return hash of [GeoData]
  String get hash => _hash;

  /// return latitude of [GeoData] -> not in original code
  double get latitude => _latitude;

  /// return longitude of [GeoData] -> not in original code
  double get longitude =>_longitude;

  /// return geographical distance between two Co-ordinates
  static double distanceBetween(
      {@required Coordinates to, @required Coordinates from}) {
    return GeoHashComputer.distance(to, from);
  }

  /// return neighboring geo-hashes of [hash]
  static List<String> neighborsOf({@required String hash}) {
    return _gHComputer.neighbors(hash);
  }


  /// return all neighbors of [GeoData]
  List<String> get neighbors {
    return _gHComputer.neighbors(this.hash);
  }

  /// return [GeoPoint] of [GeoData]
  GeoPoint get geoPoint {
    return GeoPoint(this._latitude, this._longitude);
  }

  Coordinates get coords {
    return Coordinates(this._latitude, this._longitude);
  }

  /// return distance between [GeoData] and ([lat], [lng])
  double distance({@required double lat, @required double lng}) {
    return distanceBetween(from: coords, to: Coordinates(lat, lng));
  }

  get data {
    return {'geopoint': this.geoPoint, 'geohash': this.hash};
  }

  /// haversine distance between [GeoData] and ([lat], [lng])
  haversineDistance({@required double lat, @required double lng}) {
    return GeoData.distanceBetween(
        from: coords, to: Coordinates(lat, lng));
  }
}
