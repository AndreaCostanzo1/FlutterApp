class Article {
  final String _id;

  final String _author;

  final String _title;

  final String _punchline;

  final String _text;

  final String _category;

  final String _coverImage;

  final bool _show;


  Article.fromSnapshot(Map<String, dynamic> snapshot)
      : _id = snapshot['id'],
        _show = snapshot['show'],
        _title = snapshot['title'],
        _punchline = snapshot['punchline'],
        _text= snapshot['text'],
        _category = snapshot['category'],
        _author = snapshot['author'],
        _coverImage = snapshot['coverImage'];

  bool get show => _show;

  String get category => _category;

  String get text => _text;

  String get punchline => _punchline;

  String get title => _title;

  String get author => _author;

  String get id => _id;

  String get coverImage => _coverImage;
}