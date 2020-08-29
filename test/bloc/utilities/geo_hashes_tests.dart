import 'package:flutter_beertastic/blocs/utilities/geo_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  double latitude = 48.668983;
  double longitude =-4.329021;
  GeoData geoData = GeoData(latitude, longitude);
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
}
