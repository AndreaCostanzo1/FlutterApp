import 'city.dart';

class User {
  final String _uid;
  final String _profileImagePath;
  final String _nickname;
  final String _email;
  City _city;

  User.fromSnapshot(Map<String, dynamic> snapshot)
      : _uid = snapshot['id'],
        _profileImagePath = snapshot['profile_image_path'],
        _nickname = snapshot['nickname'],
        _email = snapshot['email'],
        _city = snapshot['city_data'];

  User.empty()
      : _uid = '',
        _profileImagePath = '',
        _nickname = '',
        _email = '';

  String get uid => _uid;

  String get profileImagePath => _profileImagePath;

  String get nickname => _nickname;

  String get email => _email;

  City get city => _city;
}
