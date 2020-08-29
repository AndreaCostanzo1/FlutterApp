import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

class FirebaseFirestoreMock extends Mock implements FirebaseFirestore{

  var _result;

  FirebaseFirestoreMock.fromResult(this._result);


  set result(value) {
    _result = value;
  }

  @override
  CollectionReference collection(String collectionPath) {
    return CollectionReferenceMock(_result);
  }

}

class DocumentReferenceMock extends Mock implements DocumentReference{
  var _result;

  DocumentReferenceMock(this._result);

  @override
  CollectionReference collection(String collectionPath) {
    return CollectionReferenceMock(_result);
  }

  @override
  Stream<DocumentSnapshot> snapshots({bool includeMetadataChanges = false}) {
    return Stream.value(DocumentSnapshotMock(_result));
  }

  @override
  Future<DocumentSnapshot> get([GetOptions options]) {
    return Future.value(DocumentSnapshotMock(_result));
  }
}

class QueryMock extends Mock implements Query{
  var _result;

  QueryMock(this._result);

  @override
  Query where(field, {isEqualTo, isLessThan, isLessThanOrEqualTo, isGreaterThan, isGreaterThanOrEqualTo, arrayContains, List arrayContainsAny, List whereIn, bool isNull}) {
    return this;
  }

  @override
  Query orderBy(field, {bool descending = false}) {
    return this;
  }

  @override
  Query limit(int limit) {
    return this;
  }

  @override
  Query startAfterDocument(DocumentSnapshot documentSnapshot) {
    return this;
  }

  @override
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) {
    List<QueryDocumentSnapshot> snapshots = List();
    for(int i=0; i<_result.length; i++){
      snapshots.add(QueryDocumentSnapshotMock(_result[i]));
    }
    return Stream.value(QuerySnapshotMock(snapshots));
  }

  @override
  Future<QuerySnapshot> get([GetOptions options]) {
    List<QueryDocumentSnapshot> snapshots = List();
    for(int i=0; i<_result.length; i++){
      snapshots.add(QueryDocumentSnapshotMock(_result[i]));
    }
    return Future.value(QuerySnapshotMock(snapshots));
  }

}

class CollectionReferenceMock extends Mock implements CollectionReference{
  var _result;

  CollectionReferenceMock(this._result);


  @override
  Query where(field, {isEqualTo, isLessThan, isLessThanOrEqualTo, isGreaterThan, isGreaterThanOrEqualTo, arrayContains, List arrayContainsAny, List whereIn, bool isNull}) {
    return QueryMock(this._result);
  }

  @override
  DocumentReference doc([String path]) {
    return DocumentReferenceMock(this._result);
  }
}


class QuerySnapshotMock extends Mock implements QuerySnapshot{

  List<DocumentSnapshot> _docs;

  QuerySnapshotMock(this._docs);

  @override
  List<QueryDocumentSnapshot> get docs => _docs;
}

class QueryDocumentSnapshotMock extends Mock implements QueryDocumentSnapshot{

  Map<String,dynamic> _data;

  QueryDocumentSnapshotMock(this._data);

  @override
  Map<String,dynamic> data(){
    return _data;
  }
}

class DocumentSnapshotMock extends Mock implements DocumentSnapshot{

  Map<String,dynamic> _data;

  DocumentSnapshotMock(this._data);

  @override
  Map<String,dynamic> data(){
    return _data;
  }
}