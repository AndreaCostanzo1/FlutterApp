import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_beertastic/blocs/utilities/city_data_converter.dart';
import 'package:flutter_beertastic/blocs/utilities/geo_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){

  final String cityMockID = 'nasduqbeue2bn123133';
  final GeoData geoData = GeoData(0.0,0.0);
  final String name= 'name';
  final String imageUrl= 'image_url';
  Map<String, dynamic> convertedCityMock = {
    'id': cityMockID,
    'geo_hash': geoData.hash,
    'latitude': geoData.latitude,
    'longitude': geoData.longitude,
    'name': name,
    'image_url': imageUrl,
  };

  final Map<String,dynamic> mockCity={
    'id': cityMockID,
    'geo_hash':geoData.hash,
    'geo_point': GeoPoint(geoData.latitude,geoData.longitude),
    'name': name,
    'image_url':imageUrl,
  };

  test('test city data conversion',(){
    Map<String,dynamic> generatedConvertedCity = CityDataConverter.convertSnapshot(mockCity);
    generatedConvertedCity.remove('geo_point');
    generatedConvertedCity.forEach((key, value) => expect(value,convertedCityMock[key]));
  });
}