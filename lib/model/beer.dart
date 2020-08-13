import 'package:cloud_firestore/cloud_firestore.dart';

class Beer {
  final String _id;
  final String _name;
  final String _producer;
  final double _rating;
  final double _alcohol;
  final double _temperature;
  final String _beerImageUrl;

  Beer.fromSnapshot(Map<String, dynamic> snapshot)
      : _id = snapshot['id'],
        _name = snapshot['name'],
        _producer = snapshot['producer'],
        _rating = (snapshot['rating']??0).toDouble(),
        _alcohol = (snapshot['alcohol']??0).toDouble(),
        _temperature = (snapshot['temperature']??0).toDouble(),
        _beerImageUrl = snapshot['imageUrl'];

  String get id => _id;

  String get name => _name;

  String get producer => _producer;

  double get rating => _rating;

  double get alcohol => _alcohol;

  double get temperature => _temperature;

  String get beerImageUrl => _beerImageUrl;
}
