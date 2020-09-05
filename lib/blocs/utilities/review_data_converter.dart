import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_beertastic/model/user.dart';

class ReviewDataConverter {
  static Map<String, dynamic> convertSnapshot(Map<String, dynamic> reviewData, Map<String, dynamic> userData) {
    Map<String, dynamic> snapshotToGenerate = Map();
    snapshotToGenerate.addAll(reviewData);
    Timestamp timestamp = snapshotToGenerate['date'];
    snapshotToGenerate.update('date', (value) => timestamp.toDate());
    MyUser user=  MyUser.fromSnapshot(userData);
    snapshotToGenerate.update(
        'user', (value) =>user);
    snapshotToGenerate['id'] = user.uid;
    return snapshotToGenerate;
  }
}