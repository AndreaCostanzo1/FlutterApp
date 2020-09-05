import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:flutter_beertastic/blocs/map_bloc.dart';
import 'package:flutter_beertastic/blocs/utilities/city_data_converter.dart';
import 'package:flutter_beertastic/blocs/utilities/geo_data.dart';
import 'package:flutter_beertastic/model/city.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks/firebase_storage_mock.dart';
import 'mocks/geo_locator_mock.dart';



void main(){
  final FirebaseFirestore firestoreMock = MockFirestoreInstance();

  ///REQUIRES GEO HASH TESTS && CITY DATA CONVERTER TESTS
  final String cityMockID = 'nasduqbeue2bn123133';
  final String cityMockID2 = 'nasduqbeue2bn123132';
  final GeoData geoData = GeoData(0.0,0.0);
  final String name= 'name';
  final String imageUrl= 'image_url';
  final GeoLocatorMock geoLocatorMock= GeoLocatorMock(geoData.latitude,geoData.longitude);

  final Map<String,dynamic> mockCity={
    'id': cityMockID,
    'geo_hash':geoData.hash,
    'geo_point': GeoPoint(geoData.latitude,geoData.longitude),
    'name': name,
    'image_url':imageUrl,
  };

  final Map<String,dynamic> neighbourMockCity={
    'id': cityMockID2,
    'geo_hash':GeoData.neighborsOf(hash: geoData.hash)[0],
    //NOT PRECISE, DO NOT USE
    'geo_point': GeoPoint(geoData.latitude,geoData.longitude),
    'name': name,
    'image_url':imageUrl,
  };

  test('retrieve city image',() async {
    //GIVEN AN IMAGE TO RETRIEVE FOR A GIVEN CITY
    final FirebaseStorageMock storageMock = FirebaseStorageMock();
    City cityMockInstance = City.fromSnapshot(CityDataConverter.convertSnapshot(mockCity));


    //WHEN RETRIEVE CITY IMAGE
    MapBloc bloc = MapBloc.testConstructor(firestoreMock, storageMock, geoLocatorMock);
    Future<Uint8List> futureBeerImage =bloc.cityImageStream.first;
    bloc.retrieveCityImage(cityMockInstance);
    Uint8List beerImage = await futureBeerImage;

    //ASSERT: THE IMAGE EXISTS
    expect(beerImage!=null, true);
  });

  test('dispose',() async {
    //GIVEN AN IMAGE TO RETRIEVE FOR A GIVEN CITY
    final FirebaseStorageMock storageMock = FirebaseStorageMock();
    City cityMockInstance = City.fromSnapshot(CityDataConverter.convertSnapshot(mockCity));


    //WHEN DISPOSE
    MapBloc bloc = MapBloc.testConstructor(firestoreMock, storageMock, geoLocatorMock);
    Future<Null> run;
    Completer<Null> completer = Completer();
    run = completer.future;
    Future.delayed(Duration(milliseconds: 100), () async {
      await run;
      bloc.dispose();
    });
    Future<Uint8List> futureBeerImage =bloc.cityImageStream.last;
    bloc.retrieveCityImage(cityMockInstance);
    completer.complete();
    Uint8List beerImage = await futureBeerImage.timeout(Duration(seconds: 10));

    //ASSERT: THE IMAGE EXISTS
    expect(beerImage!=null, true);
  });
}