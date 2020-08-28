import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_beertastic/blocs/authenticator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'utilities/firebase_auth_mock.dart';


void main() {
  MockFirebaseAuth firebaseMockAuth= MockFirebaseAuth();
  String existingUserEmail = 'mario.rossi@gmail.com';
  String nonExistingUserEmail = 'andrea@gmail.com';
  String validButWrongPassword = '123445';
  String existingUserPassword= '123456';
  String invalidEmail = 'mario.rossigmail.com';
  String invalidPassword='12345';
  String unexpectedExceptionEmail = 'mario.bianchi@gmail.com';
  String unexpectedExceptionPassword = '111111';




  group('Login tests', () {
    test('Wrong Email Pattern', () async {
      Authenticator authenticator= Authenticator.testConstructor(firebaseMockAuth);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(seconds: 1), () async {
        await run;
        authenticator.logWithEmailAndPassword(invalidEmail, existingUserPassword);
      });
      Future<RemoteError> futureError =authenticator.remoteError.first.timeout(Duration(seconds: 10));
      completer.complete();
      RemoteError error = await futureError;
      expect(error, RemoteError.EMAIL_FORMAT);
    });

    test('Wrong Password Pattern', () async {
      Authenticator authenticator= Authenticator.testConstructor(firebaseMockAuth);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(seconds: 1), () async {
        await run;
        authenticator.logWithEmailAndPassword(existingUserEmail, invalidPassword);
      });
      Future<RemoteError> futureError =authenticator.remoteError.first.timeout(Duration(seconds: 10));
      completer.complete();
      RemoteError error = await futureError;
      expect(error, RemoteError.PASSWORD_FORMAT);
    });

    //TEST FOR VALID EMAIL BUT USER NOT EXISTING
    when(firebaseMockAuth.signInWithEmailAndPassword(email: nonExistingUserEmail, password: existingUserPassword)).thenThrow(MockFirebaseAuthException('user-not-found'));
    test('User non existing', () async {
      Authenticator authenticator= Authenticator.testConstructor(firebaseMockAuth);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(seconds: 1), () async {
        await run;
        authenticator.logWithEmailAndPassword(nonExistingUserEmail, existingUserPassword);
      });
      Future<RemoteError> futureError =authenticator.remoteError.first.timeout(Duration(seconds: 10));
      completer.complete();
      RemoteError error = await futureError;
      expect(error, RemoteError.USER_NOT_FOUND);
    });

    //TEST FOR WRONG BUT VALID PASSWORD
    when(firebaseMockAuth.signInWithEmailAndPassword(email: existingUserEmail, password: validButWrongPassword)).thenThrow(MockFirebaseAuthException('wrong-password'));
    test('Wrong password but valid', () async {
      Authenticator authenticator= Authenticator.testConstructor(firebaseMockAuth);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(seconds: 1), () async {
        await run;
        authenticator.logWithEmailAndPassword(existingUserEmail, validButWrongPassword);
      });
      Future<RemoteError> futureError =authenticator.remoteError.first.timeout(Duration(seconds: 10));
      completer.complete();
      RemoteError error = await futureError;
      expect(error, RemoteError.WRONG_PASSWORD);
    });

    //TEST FOR UNEXPECTED EXCEPTION
    when(firebaseMockAuth.signInWithEmailAndPassword(email: unexpectedExceptionEmail, password: unexpectedExceptionPassword)).thenThrow(MockFirebaseAuthException('????????'));
    test('Not expected exception during login', () async {
      Authenticator authenticator= Authenticator.testConstructor(firebaseMockAuth);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(seconds: 1), () async {
        await run;
        authenticator.logWithEmailAndPassword(unexpectedExceptionEmail, unexpectedExceptionPassword);
      });
      Future<RemoteError> futureError =authenticator.remoteError.first.timeout(Duration(seconds: 10));
      completer.complete();
      RemoteError error = await futureError;
      expect(error, RemoteError.NOT_DEFINED);
    });

  });

  group('Registration tests', () {
    test('Wrong Email Pattern', () async {
      Authenticator authenticator= Authenticator.testConstructor(firebaseMockAuth);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(seconds: 1), () async {
        await run;
        authenticator.signUpWithEmailAndPassword(invalidEmail, existingUserPassword,existingUserPassword);
      });
      Future<RemoteError> futureError =authenticator.remoteError.first.timeout(Duration(seconds: 10));
      completer.complete();
      RemoteError error = await futureError;
      expect(error, RemoteError.EMAIL_FORMAT);
    });

    test('Wrong Password Pattern', () async {
      Authenticator authenticator= Authenticator.testConstructor(firebaseMockAuth);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(seconds: 1), () async {
        await run;
        authenticator.signUpWithEmailAndPassword(existingUserEmail, invalidPassword,invalidPassword);
      });
      Future<RemoteError> futureError =authenticator.remoteError.first.timeout(Duration(seconds: 10));
      completer.complete();
      RemoteError error = await futureError;
      expect(error, RemoteError.PASSWORD_FORMAT);
    });

    test('Different Confirm Password', () async {
      Authenticator authenticator= Authenticator.testConstructor(firebaseMockAuth);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(seconds: 1), () async {
        await run;
        authenticator.signUpWithEmailAndPassword(existingUserEmail, existingUserPassword,existingUserPassword+'1');
      });
      Future<RemoteError> futureError =authenticator.remoteError.first.timeout(Duration(seconds: 10));
      completer.complete();
      RemoteError error = await futureError;
      expect(error, RemoteError.NOT_MATCHING_PASSWORDS);
    });

    //TEST FOR VALID EMAIL BUT USER NOT EXISTING
    when(firebaseMockAuth.createUserWithEmailAndPassword(email: existingUserEmail, password: existingUserPassword)).thenThrow(MockFirebaseAuthException('email-already-in-use'));
    test('User already existing', () async {
      Authenticator authenticator= Authenticator.testConstructor(firebaseMockAuth);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(seconds: 1), () async {
        await run;
        authenticator.signUpWithEmailAndPassword(existingUserEmail, existingUserPassword,existingUserPassword);
      });
      Future<RemoteError> futureError =authenticator.remoteError.first.timeout(Duration(seconds: 10));
      completer.complete();
      RemoteError error = await futureError;
      expect(error, RemoteError.USER_ALREADY_EXIST);
    });

    //TEST FOR UNEXPECTED EXCEPTION
    when(firebaseMockAuth.createUserWithEmailAndPassword(email: unexpectedExceptionEmail, password: unexpectedExceptionPassword)).thenThrow(MockFirebaseAuthException('????????'));
    test('Not expected exception during sign up', () async {
      Authenticator authenticator= Authenticator.testConstructor(firebaseMockAuth);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(seconds: 1), () async {
        await run;
        authenticator.signUpWithEmailAndPassword(unexpectedExceptionEmail, unexpectedExceptionPassword,unexpectedExceptionPassword);
      });
      Future<RemoteError> futureError =authenticator.remoteError.first.timeout(Duration(seconds: 10));
      completer.complete();
      RemoteError error = await futureError;
      expect(error, RemoteError.NOT_DEFINED);
    });
  });


  group('Reset Password Email', (){
    when(firebaseMockAuth.sendPasswordResetEmail(email: nonExistingUserEmail)).thenThrow(MockFirebaseAuthException('user-not-found'));
    test('User non existing', () async {
      Authenticator authenticator= Authenticator.testConstructor(firebaseMockAuth);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(seconds: 1), () async {
        await run;
        authenticator.sendPasswordResetEmail(nonExistingUserEmail);
      });
      Future<RemoteError> futureError =authenticator.remoteError.first.timeout(Duration(seconds: 10));
      completer.complete();
      RemoteError error = await futureError;
      expect(error, RemoteError.USER_NOT_FOUND);
    });
  });

  group('Delete account', (){
    when(firebaseMockAuth.currentUser.delete()).thenThrow(MockFirebaseAuthException('requires-recent-login'));
    test('Requires recent login', () async {
      Authenticator authenticator= Authenticator.testConstructor(firebaseMockAuth);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(seconds: 1), () async {
        await run;
        authenticator.deleteAccount();
      });
      Future<RemoteError> futureError =authenticator.remoteError.first.timeout(Duration(seconds: 10));
      completer.complete();
      RemoteError error = await futureError;
      expect(error, RemoteError.REQUIRES_RECENT_LOGIN);
    });
  });
}
