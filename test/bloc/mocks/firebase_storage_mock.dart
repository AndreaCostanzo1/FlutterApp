import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mockito/mockito.dart';

class FirebaseStorageMock extends Mock implements FirebaseStorage{

  @override
  StorageReference ref() {
    return StorageReferenceMock();
  }
}

class StorageReferenceMock extends Mock implements StorageReference{
  @override
  StorageReference child(String path) {
    return this;
  }

  Future<Uint8List> getData(int size){
    return Future.value(Uint8List(10));
  }
}