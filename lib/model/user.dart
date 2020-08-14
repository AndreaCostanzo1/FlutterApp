class User {
  String _uid;
  String _profileImagePath;

  User.fromSnapshot(Map<String, dynamic> snapshot)
      : _uid = snapshot['id'],
        _profileImagePath = snapshot['profile_image_path'];

  String get uid => _uid;

  String get profileImagePath => _profileImagePath;
}
