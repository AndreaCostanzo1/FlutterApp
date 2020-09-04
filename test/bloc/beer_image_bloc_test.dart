import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_beertastic/blocs/beer_image_bloc.dart';
import 'package:flutter_beertastic/model/beer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks/firebase_storage_mock.dart';

void main(){
  final String beerMockID = 'duiqa98e21y1nquhdsau';
  Map<String, dynamic> beerMock = {
    'id': beerMockID,
    'name': '_name',
    'producer': '_producer',
    'rating': 4,
    'alcohol': 4,
    'temperature': 4,
    'beerImageUrl': '_beerImageUrl',
    'style': '_style',
    'color': '_color',
    'carbonation': 2.1,
    'searches': 0,
    'likes': 0,
  };

  group('beer image bloc tests',(){
    test('retrieve image', () async{
      FirebaseStorageMock storageMock = FirebaseStorageMock();
      BeerImageBloc _bloc =BeerImageBloc.testConstructor(storageMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveBeerImage(Beer.fromSnapshot(beerMock));
      });
      Future<Uint8List> futureBeerImage =_bloc.beerImageStream.first;
      completer.complete();
      Uint8List beerImage = await futureBeerImage;
      expect(beerImage!=null, true);
    });

    test('dispose',() async {
      FirebaseStorageMock storageMock = FirebaseStorageMock();
      BeerImageBloc _bloc =BeerImageBloc.testConstructor(storageMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.dispose();
      });
      Future<Uint8List> futureBeerImage =_bloc.beerImageStream.last;
      _bloc.retrieveBeerImage(Beer.fromSnapshot(beerMock));
      completer.complete();
      Uint8List beerImage = await futureBeerImage.timeout(Duration(seconds: 10));
      expect(beerImage!=null, true);
    });
  });
}