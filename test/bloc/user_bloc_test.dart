import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beertastic/blocs/user_bloc.dart';
import 'package:flutter_beertastic/blocs/utilities/city_data_converter.dart';
import 'package:flutter_beertastic/model/city.dart';
import 'package:flutter_beertastic/model/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/firebase_auth_mock.dart';
import 'mocks/firebase_storage_mock.dart';

void main() {
  final FirebaseAuthMock authMock = FirebaseAuthMock();
  final FirebaseFirestore firestoreMock = MockFirestoreInstance();
  final String cityMockID = 'nasduqbeue2bn123133';
  final String profileImageMockPath = 'one/two/three';

  final Map<String, dynamic> mockUser = {
    'id': authMock.currentUser.uid,
    'profile_image_path': profileImageMockPath,
    'nickname': 'nick',
    'email': authMock.currentUser.uid,
    'city': firestoreMock.collection('cities').doc(cityMockID),
  };

  final Map<String,dynamic> mockCity={
    'geo_hash':'u0nd9hkpc',
    'geo_point': GeoPoint(45.46416,9.1901083),
    'id': cityMockID,
    'name': 'name',
    'image_url':'url',
  };

  group('get user image tests', () {
    test('user image available', () async {
      //GIVEN AN IMAGE IN STORAGE
      final FirebaseStorage storageMock = FirebaseStorageMock();

      //WHEN: RETRIEVE USER IMAGE
      UserBloc userBloc =
          UserBloc.testConstructor(authMock, firestoreMock, storageMock);
      Future<ImageProvider> futureProvider = userBloc.userImageStream.first;
      userBloc.getUserImage('..');
      ImageProvider provider = await futureProvider;
      //ASSERT: MEMORY IMAGE TYPE
      expect(provider.runtimeType, MemoryImage);
    });

    test('user image not available', () async {
      //GIVEN NO IMAGE IN STORAGE
      final FirebaseStorage storageMock = FirebaseStorageMock.returnError();

      //WHEN: RETRIEVE USER IMAGE
      UserBloc userBloc =
          UserBloc.testConstructor(authMock, firestoreMock, storageMock);
      Future<ImageProvider> futureProvider = userBloc.userImageStream.first;
      userBloc.getUserImage('');
      ImageProvider provider = await futureProvider;
      //ASSERT: ASSET IMAGE TYPE (from local device)
      expect(provider.runtimeType, AssetImage);
    });
  });

  group('get authenticated user data tests', () {
    test('get authenticated user data without listening image stream',()async{
      //GIVEN A USER WITH CITY AND AN IMAGE IN STORAGE
      firestoreMock.collection('cities').doc(cityMockID).set(mockCity);
      firestoreMock.collection('users').doc(authMock.currentUser.uid).set(mockUser);
      final FirebaseStorage storageMock = FirebaseStorageMock();

      //WHEN: GET AUTHENTICATED USER DATA
      UserBloc bloc = UserBloc.testConstructor(authMock, firestoreMock, storageMock);
      Future<MyUser> futureUser = bloc.authenticatedUserStream.first;
      bloc.getAuthenticatedUserData();
      MyUser user = await futureUser;

      //ASSERT: USER ID AND CITY ID MATCH.
      expect(user.uid, authMock.currentUser.uid);
      expect(user.city.id,cityMockID);

      //AFTER: CLEAR DB
      await firestoreMock.collection('cities').doc(cityMockID).delete();
      await firestoreMock.collection('users').doc(authMock.currentUser.uid).delete();
    });

    test('get authenticated user data with image',()async{
      //GIVEN A USER WITH CITY AND AN IMAGE IN STORAGE
      firestoreMock.collection('cities').doc(cityMockID).set(mockCity);
      firestoreMock.collection('users').doc(authMock.currentUser.uid).set(mockUser);
      final FirebaseStorage storageMock = FirebaseStorageMock();

      //WHEN: GET AUTHENTICATED USER DATA
      UserBloc bloc = UserBloc.testConstructor(authMock, firestoreMock, storageMock);
      Future<MyUser> futureUser = bloc.authenticatedUserStream.first;
      Future<ImageProvider> futureProvider= bloc.profileImageStream.first;
      bloc.getAuthenticatedUserData();
      MyUser user = await futureUser;
      ImageProvider provider = await futureProvider;

      //ASSERT: USER ID AND CITY ID MATCH.
      expect(user.uid, authMock.currentUser.uid);
      expect(user.city.id,cityMockID);
      expect(provider.runtimeType,MemoryImage);

      //AFTER: CLEAR DB
      await firestoreMock.collection('cities').doc(cityMockID).delete();
      await firestoreMock.collection('users').doc(authMock.currentUser.uid).delete();
    });

    test('get authenticated user data without image',()async{
      //GIVEN A USER WITH CITY AND AN IMAGE IN STORAGE
      firestoreMock.collection('cities').doc(cityMockID).set(mockCity);
      firestoreMock.collection('users').doc(authMock.currentUser.uid).set(mockUser);
      final FirebaseStorage storageMock = FirebaseStorageMock.returnError();

      //WHEN: GET AUTHENTICATED USER DATA
      UserBloc bloc = UserBloc.testConstructor(authMock, firestoreMock, storageMock);
      Future<MyUser> futureUser = bloc.authenticatedUserStream.first;
      Future<ImageProvider> futureProvider= bloc.profileImageStream.first;
      bloc.getAuthenticatedUserData();
      MyUser user = await futureUser;
      String error;
      try {
        await futureProvider;
      } catch(e){
        error=e.toString();
      }

      //ASSERT: USER ID AND CITY ID MATCH.
      expect(user.uid, authMock.currentUser.uid);
      expect(user.city.id,cityMockID);
      expect(error,UserBloc.imageNotFoundError);

      //AFTER: CLEAR DB
      await firestoreMock.collection('cities').doc(cityMockID).delete();
      await firestoreMock.collection('users').doc(authMock.currentUser.uid).delete();
    });
  });

  group('get profile image path tests',(){
    test('get profile image path',()async{
      //GIVEN A USER WITH CITY AND AN IMAGE IN STORAGE
      firestoreMock.collection('cities').doc(cityMockID).set(mockCity);
      firestoreMock.collection('users').doc(authMock.currentUser.uid).set(mockUser);
      final FirebaseStorage storageMock = FirebaseStorageMock();

      //WHEN: GET PROFILE IMAGE PATH
      UserBloc bloc = UserBloc.testConstructor(authMock, firestoreMock, storageMock);
      String imagePath = await bloc.getProfileImagePath();

      //ASSERT: PROFILE IMAGE PATHS MATCH
      expect(imagePath, profileImageMockPath);

      //AFTER: CLEAR DB
      await firestoreMock.collection('cities').doc(cityMockID).delete();
      await firestoreMock.collection('users').doc(authMock.currentUser.uid).delete();
    });
  });

  group('set information tests',(){
    test('set information',()async{
      //GIVEN A USER AND NEW CITY ID AND NICKNAME TO SET
      await firestoreMock.collection('users').doc(authMock.currentUser.uid).set(mockUser);
      final FirebaseStorage storageMock = FirebaseStorageMock();
      final String newMockCityId='anquh198h312aa';
      final String newMockNickname='my nick';
      final Map<String,dynamic> newMockCity = Map.from(mockCity);
      newMockCity.update('id', (value) => newMockCityId);
      await firestoreMock.collection('cities').doc(newMockCityId).set(newMockCity);

      //WHEN: SET INFORMATION
      UserBloc bloc = UserBloc.testConstructor(authMock, firestoreMock, storageMock);
      City mockCityInstance= City.fromSnapshot(CityDataConverter.convertSnapshot(newMockCity));
      await bloc.setInformation(newMockNickname, mockCityInstance);

      //ASSERT: NICKNAME AND CITY REFERENCE ARE UPDATED
      DocumentReference expectedRef= firestoreMock.collection('cities').doc(newMockCityId);
      Map<String,dynamic> snapshot = (await firestoreMock.collection('users').doc(authMock.currentUser.uid).get()).data();
      expect(snapshot['city'],expectedRef);
      expect(snapshot['nickname'], newMockNickname);

      //AFTER: CLEAR DB
      await firestoreMock.collection('cities').doc(newMockCityId).delete();
      await firestoreMock.collection('users').doc(authMock.currentUser.uid).delete();
    });
  });

  group('listen authenticated user data tests', () {
    test('listen authenticated user data without listening image stream',()async{
      //GIVEN A USER WITH CITY AND AN IMAGE IN STORAGE
      firestoreMock.collection('cities').doc(cityMockID).set(mockCity);
      firestoreMock.collection('users').doc(authMock.currentUser.uid).set(mockUser);
      final FirebaseStorage storageMock = FirebaseStorageMock();

      //WHEN: GET AUTHENTICATED USER DATA
      UserBloc bloc = UserBloc.testConstructor(authMock, firestoreMock, storageMock);
      Future<MyUser> futureUser = bloc.authenticatedUserStream.first;
      bloc.listenToAuthenticatedUserData();
      MyUser user = await futureUser;

      //ASSERT: USER ID AND CITY ID MATCH.
      expect(user.uid, authMock.currentUser.uid);
      expect(user.city.id,cityMockID);

      //AFTER: CLEAR DB
      await firestoreMock.collection('cities').doc(cityMockID).delete();
      await firestoreMock.collection('users').doc(authMock.currentUser.uid).delete();
    });

    test('listen authenticated user data with image',()async{
      //GIVEN A USER WITH CITY AND AN IMAGE IN STORAGE
      firestoreMock.collection('cities').doc(cityMockID).set(mockCity);
      firestoreMock.collection('users').doc(authMock.currentUser.uid).set(mockUser);
      final FirebaseStorage storageMock = FirebaseStorageMock();

      //WHEN: GET AUTHENTICATED USER DATA
      UserBloc bloc = UserBloc.testConstructor(authMock, firestoreMock, storageMock);
      Future<MyUser> futureUser = bloc.authenticatedUserStream.first;
      Future<ImageProvider> futureProvider= bloc.profileImageStream.first;
      bloc.listenToAuthenticatedUserData();
      MyUser user = await futureUser;
      ImageProvider provider = await futureProvider;

      //ASSERT: USER ID AND CITY ID MATCH.
      expect(user.uid, authMock.currentUser.uid);
      expect(user.city.id,cityMockID);
      expect(provider.runtimeType,MemoryImage);

      //AFTER: CLEAR DB
      await firestoreMock.collection('cities').doc(cityMockID).delete();
      await firestoreMock.collection('users').doc(authMock.currentUser.uid).delete();
    });

    test('listen authenticated user data without image',()async{
      //GIVEN A USER WITH CITY AND AN IMAGE IN STORAGE
      firestoreMock.collection('cities').doc(cityMockID).set(mockCity);
      firestoreMock.collection('users').doc(authMock.currentUser.uid).set(mockUser);
      final FirebaseStorage storageMock = FirebaseStorageMock.returnError();

      //WHEN: GET AUTHENTICATED USER DATA
      UserBloc bloc = UserBloc.testConstructor(authMock, firestoreMock, storageMock);
      Future<MyUser> futureUser = bloc.authenticatedUserStream.first;
      Future<ImageProvider> futureProvider= bloc.profileImageStream.first;
      bloc.listenToAuthenticatedUserData();
      MyUser user = await futureUser;
      String error;
      try {
        await futureProvider;
      } catch(e){
        error=e.toString();
      }

      //ASSERT: USER ID AND CITY ID MATCH.
      expect(user.uid, authMock.currentUser.uid);
      expect(user.city.id,cityMockID);
      expect(error,UserBloc.imageNotFoundError);

      //AFTER: CLEAR DB
      await firestoreMock.collection('cities').doc(cityMockID).delete();
      await firestoreMock.collection('users').doc(authMock.currentUser.uid).delete();
    });
  });
}
