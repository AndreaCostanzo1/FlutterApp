import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mockito/mockito.dart';

class FirebaseStorageMock extends Mock implements FirebaseStorage{

  final bool _returnError;

  FirebaseStorageMock():_returnError=false;

  FirebaseStorageMock.returnError():_returnError=true;

  @override
  StorageReference ref() {
    if(!_returnError){
      return StorageReferenceMock();
    } else{
      return StorageReferenceMock.withError();
    }
  }
}

class StorageReferenceMock extends Mock implements StorageReference{

  final bool _returnError;

  StorageReferenceMock():_returnError=false;

  StorageReferenceMock.withError():_returnError=true;

  @override
  StorageReference child(String path) {
    return this;
  }

  Future<Uint8List> getData(int size){
    if(!_returnError){
      return Future.value(Uint8List(10));
    } else {
      return Future.error(Exception());
    }
  }


}