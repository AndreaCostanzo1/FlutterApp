import 'package:flutter_beertastic/model/user.dart';

class Review {
  final String _id;
  final String _comment;
  final int _rate;
  final MyUser _user;

  Review.fromSnapshot(Map<String, dynamic> snapshot)
      : _id=snapshot['id'],
        _comment = snapshot['comment'],
        _rate = (snapshot['rate']).toInt(),
        _user= snapshot['user'];

  Review.empty():_id='',
        _comment = '',
        _rate = 0,
        _user= MyUser.empty();

  String get comment => _comment;

  int get rate => _rate;

  MyUser get user => _user;

  String get id =>_id;
}
