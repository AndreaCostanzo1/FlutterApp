class City {
  final String _id;
  final String _geoHash;
  final double _latitude;
  final double _longitude;
  final String _name;
  final String _imageUrl;

  City.fromSnapshot(Map<String, dynamic> snapshot)
      : _id = snapshot['id'],
        _geoHash = snapshot['geo_hash'],
        _latitude = snapshot['latitude'],
        _longitude = snapshot['longitude'],
        _name = snapshot['name'],
        _imageUrl = snapshot['image_url'];

  String get imageUrl => _imageUrl;

  String get name => _name;

  double get longitude => _longitude;

  double get latitude => _latitude;

  String get geoHash => _geoHash;

  String get id => _id;
}
