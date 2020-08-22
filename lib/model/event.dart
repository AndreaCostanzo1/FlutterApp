class Event {
  final String _id;
  final String _title;
  final String _reducedTitle;
  final String _punchLine;
  final String _description;
  final String _imageUrl;
  final String _placeName;
  final DateTime _date;
  final double _latitude;
  final double _longitude;

  Event.fromSnapshot(Map<String, dynamic> snapshot)
      : _id = snapshot['id'],
        _title = snapshot['title'],
        _reducedTitle = snapshot['reduced_title'],
        _punchLine = snapshot['punch_line'],
        _description = snapshot['description'],
        _imageUrl = snapshot['image_url'],
        _placeName = snapshot['place'],
        _date = snapshot['date'],
        _latitude = snapshot['latitude'],
        _longitude = snapshot['longitude'];

  Event.empty()
      : _id = '',
        _title = '',
        _reducedTitle = '',
        _punchLine = '',
        _description = '',
        _imageUrl = '',
        _placeName = '',
        _date = DateTime.now(),
        _latitude = 0,
        _longitude = 0;

  double get longitude => _longitude;

  double get latitude => _latitude;

  DateTime get date => _date;

  String get placeName => _placeName;

  String get imageUrl => _imageUrl;

  String get description => _description;

  String get punchLine => _punchLine;

  String get reducedTitle => _reducedTitle;

  String get title => _title;

  String get id => _id;

  Map<String, dynamic> toJson() {
    return Map.from({
      'id':_id,
      'date': _date,
      'description': _description,
      'title': _imageUrl,
      'punch_line': _punchLine,
    });
  }
}
