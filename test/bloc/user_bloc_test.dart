import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beertastic/blocs/user_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/firebase_auth_mock.dart';
import 'mocks/firebase_storage_mock.dart';

void main(){
  final FirebaseAuthMock authMock = FirebaseAuthMock();
  final FirebaseFirestore firestoreMock = MockFirestoreInstance();


  group('get user image tests',(){
    test('user image available',() async {
      //GIVEN AN IMAGE IN STORAGE
      final FirebaseStorage storageMock = FirebaseStorageMock();

      //WHEN: RETRIEVE USER IMAGE
      UserBloc userBloc = UserBloc.testConstructor(authMock,firestoreMock,storageMock);
      Future<ImageProvider> futureProvider = userBloc.userImageStream.first;
      userBloc.getUserImage('..');
      ImageProvider provider= await futureProvider;
      //ASSERT: MEMORY IMAGE TYPE
      expect(provider.runtimeType, MemoryImage);
    });


    test('user image not available',() async {
      //GIVEN NO IMAGE IN STORAGE
      final FirebaseStorage storageMock = FirebaseStorageMock.returnError();

      //WHEN: RETRIEVE USER IMAGE
      UserBloc userBloc = UserBloc.testConstructor(authMock,firestoreMock,storageMock);
      Future<ImageProvider> futureProvider = userBloc.userImageStream.first;
      userBloc.getUserImage('');
      ImageProvider provider= await futureProvider;
      //ASSERT: ASSET IMAGE TYPE (from local device)
      expect(provider.runtimeType, AssetImage);
    });
  });
}