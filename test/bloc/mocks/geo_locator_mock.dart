import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';

class GeoLocatorMock extends Mock implements Geolocator{
  final double _latitude;
  final double _longitude;

  GeoLocatorMock(this._latitude, this._longitude);

  @override
  Future<Position> getCurrentPosition({LocationAccuracy desiredAccuracy = LocationAccuracy.best, GeolocationPermission locationPermissionLevel = GeolocationPermission.location}) {
    return Future.value(Position(latitude: _latitude,longitude: _longitude));
  }
}