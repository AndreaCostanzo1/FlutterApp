import 'package:cloud_firestore/cloud_firestore.dart';

class Beer {
  final String _documentID;
  final String _name;
  final String _producer;
  final double _rating;
  final double _alcohol;
  final double _temperature;
  final String _beerImageUrl;

  Beer.fromSnapshot(DocumentSnapshot snapshot)
      : _documentID = snapshot?.documentID,
        _name = snapshot['name'],
        _producer = snapshot['producer'],
        _rating = snapshot['rating'].toDouble(),
        _alcohol = snapshot['alcohol'].toDouble(),
        _temperature = snapshot['temperature'].toDouble(),
        _beerImageUrl = snapshot['imageUrl'];

  String get name => _name;

  String get producer => _producer;

  double get rating => _rating;

  double get alcohol => _alcohol;

  double get temperature => _temperature;

  String get beerImageUrl => _beerImageUrl;
}
