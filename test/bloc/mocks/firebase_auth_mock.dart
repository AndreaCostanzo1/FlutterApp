import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class FirebaseAuthMock extends Mock implements FirebaseAuth {
  final User _currentUser;

  FirebaseAuthMock(): this._currentUser=MockUser('anudahjqwuehq2xa21', 'andrea@gmail.com');

  @override
  User get currentUser => _currentUser;
}

class MockUser extends Mock implements User{
  final String _uid;
  final String _email;

  MockUser(this._uid,this._email);

  @override
  String get uid =>_uid;

  @override
  String get email =>_email;

}

class MockUserCredentials extends Mock implements UserCredential{
  User _user;

  MockUserCredentials(this._user);

  @override
  User get user=> _user;
}

class MockFirebaseAuthException extends Mock implements FirebaseAuthException{
  String _code;

  MockFirebaseAuthException(this._code);

  @override
  String get code => _code;
}
