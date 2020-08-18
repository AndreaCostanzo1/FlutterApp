import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_beertastic/model/user.dart';

class Review {
  final String _comment;
  final int _rate;
  final User _user;
  Review.fromSnapshot(Map<String, dynamic> snapshot)
      : _comment = snapshot['comment'],
        _rate = (snapshot['rate']).toInt(),
        _user= snapshot['user'];

  String get comment => _comment;

  int get rate => _rate;

  User get user => _user;
}
