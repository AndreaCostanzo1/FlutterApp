import 'dart:async';

import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_beertastic/model/beer.dart';
import 'package:synchronized/synchronized.dart';

class BeerImageBloc {

  final StreamController<Uint8List> _beerImageController= StreamController.broadcast();

  Stream<Uint8List> get beerImageStream => _beerImageController.stream;

  final FirebaseStorage _firebaseStorage;

  BeerImageBloc(): _firebaseStorage= FirebaseStorage.instance;

  BeerImageBloc.testConstructor(FirebaseStorage storage): _firebaseStorage= storage;

  Lock _lock = Lock();

  void dispose()async{
    await _lock.synchronized(() => _beerImageController.close());
  }

  Future<void> retrieveBeerImage(Beer beer) async {
    Uint8List image = await _firebaseStorage
        .ref()
        .child(beer.beerImageUrl ?? 'beer_images/beer_generic.jpg')
        .getData(10000000);
    await _lock.synchronized(() {
      if(!_beerImageController.isClosed) _beerImageController.sink.add(image);
    });
    return null;
  }
}