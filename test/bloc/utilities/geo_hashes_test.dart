import 'package:flutter_beertastic/blocs/utilities/geo_data.dart';
import 'package:flutter_beertastic/blocs/utilities/geo_hash_computer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  double latitude = 48.668983;
  double longitude =-4.329021;
  double zeroLat=0;
  double zeroLong=0;
  GeoData geoData = GeoData(latitude, longitude);
  GeoData zeroCoord= GeoData(zeroLat, zeroLong);
  String geoHash= 'gbsuv7ztq';
  List<String> expectedNeighbors = [
    'gbsuv7ztt',
    'gbsuv7ztw',
    'gbsuv7ztx',
    'gbsuv7ztm',
    'gbsuv7ztr',
    'gbsuv7ztj',
    'gbsuv7ztn',
    'gbsuv7ztp'
  ];
  expectedNeighbors.sort();


  test('geo hash encoder', () {
    expect(geoData.hash, geoHash);
  });

  test('neighbour',(){
    List<String> actualNeighbors = geoData.neighbors;
    actualNeighbors.sort();
    expect(actualNeighbors, expectedNeighbors);
  });

  test('distance',(){
    double distance = geoData.distance(lat: zeroLat, lng: zeroLong);
    expect(distance>=5420&&distance<=5430, true);
  });

  test('precisions',(){
    Map<double,int> precisions ={
      GeoHashComputer.PRECISION_KM_1:1,
      GeoHashComputer.PRECISION_KM_2:2,
      GeoHashComputer.PRECISION_KM_3:3,
      GeoHashComputer.PRECISION_KM_4:4,
      GeoHashComputer.PRECISION_KM_5:5,
      GeoHashComputer.PRECISION_KM_6:6,
      GeoHashComputer.PRECISION_KM_7:7,
      GeoHashComputer.PRECISION_KM_8:8,
      GeoHashComputer.PRECISION_KM_9:9,
    };

    //ENSURE THAT PRECISIONS AND KMs ARE CORRECTLY BOUND
    precisions.forEach((key, value) => expect(GeoHashComputer.setPrecision(key),value));
  });
}
