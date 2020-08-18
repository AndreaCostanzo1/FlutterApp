class Review{

  final String _comment;

  Review.fromSnapshot(Map<String,dynamic > snapshot):
  _comment=snapshot['comment'];

  String get comment => _comment;

}