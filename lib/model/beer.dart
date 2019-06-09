import 'package:cloud_firestore/cloud_firestore.dart';

class Beer {
  final String _documentID;
  final String _name;
  final String _producer;
  final double _rating;

  Beer.fromSnapshot(DocumentSnapshot snapshot)
      : _documentID = snapshot?.documentID,
        _name = snapshot['name'],
        _producer = snapshot['producer'],
        _rating = snapshot['rating'].toDouble();

  String get name => _name;

  String get producer => _producer;

  double get rating => _rating;
}
