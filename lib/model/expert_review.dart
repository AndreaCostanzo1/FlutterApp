class ExpertReview {
  final String _id;

  final String _author;

  final String _title;

  final String _text;

  final String _coverImage;

  final String _source;

  final List<Subsection> _subsections;

  ExpertReview.fromSnapshot(Map<String, dynamic> snapshot)
      : _id = snapshot['id'],
        _title = snapshot['title'],
        _text = snapshot['text'],
        _author = snapshot['author'],
        _coverImage = snapshot['cover_image'],
        _source = snapshot['source'],
        _subsections = List.from(snapshot['subsections'] ?? [])
            .map((subsection) => Subsection.fromSnapshot(subsection))
            .toList();

  ExpertReview.empty()
      : _id = '',
        _title = '',
        _text = '',
        _author = '',
        _coverImage = '',
        _source = '',
        _subsections = [];

  String get text => _text;

  String get title => _title;

  String get author => _author;

  String get id => _id;

  String get coverImage => _coverImage;

  List<Subsection> get subsections => _subsections;

  String get source => _source;
}

class Subsection {
  final String _title;
  final String _text;
  final String _image;

  Subsection.fromSnapshot(subsection)
      : _title = subsection['title'],
        _text = subsection['text'],
        _image = subsection['image'];

  String get text => _text;

  String get title => _title;

  String get image => _image;
}
