class User {
  String _uid;
  String _profileImagePath;
  String _nickname;

  User.fromSnapshot(Map<String, dynamic> snapshot)
      : _uid = snapshot['id'],
        _profileImagePath = snapshot['profile_image_path'],
        _nickname = snapshot['nickname'];

  User.empty()
      : _uid = '',
        _profileImagePath = '',
        _nickname = '';

  String get uid => _uid;

  String get profileImagePath => _profileImagePath;

  String get nickname => _nickname;
}
