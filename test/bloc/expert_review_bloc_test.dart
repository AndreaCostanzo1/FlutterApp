import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:flutter_beertastic/blocs/expert_review_bloc.dart';
import 'package:flutter_beertastic/model/beer.dart';
import 'package:flutter_beertastic/model/expert_review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final FirebaseFirestore firestoreMock = MockFirestoreInstance();
  String beerMockID = '113213131231231asdasf';
  String expertReviewMockID = 'naduqn912he8nqheduan';
  Map<String, dynamic> beerMock = {
    'id': beerMockID,
    'name': '_name',
    'producer': '_producer',
    'rating': 4,
    'expert_review': firestoreMock
        .collection('beers')
        .doc(beerMockID)
        .collection('expert_reviews')
        .doc(expertReviewMockID),
    'alcohol': 4,
    'temperature': 4,
    'beerImageUrl': '_beerImageUrl',
    'style': '_style',
    'color': '_color',
    'carbonation': 2.1,
    'searches': 0,
    'likes': 0,
  };

  Map<String,dynamic> expertReviewMock ={
  'id': expertReviewMockID,
  'title':'',
  'text':'',
  'author':'',
  'cover_image':'',
  'source':'',
  'subsections' : []
  };

  group('expert reviews bloc tests', () {
    test('get expert review when it is available', () async {
      //GIVEN: AN EXPERT REVIEW FOR A BEER
      DocumentReference beerRef= firestoreMock.collection('beers').doc(beerMockID);
      beerRef.set(beerMock);
      beerRef.collection('expert_reviews').doc(expertReviewMockID).set(expertReviewMock);

      //WHEN: RETRIEVE REVIEW
      ExpertReviewBloc _bloc = ExpertReviewBloc.testConstructor(firestoreMock);
      Future<ExpertReview> futureExpertReview= _bloc.reviewStream.first;
      _bloc.retrieveReview(Beer.fromSnapshot(beerMock));
      ExpertReview expertReview = await futureExpertReview;

      //ASSERT: EXPERT REVIEW IS FOUND
      expect(expertReview.id,expertReviewMockID);

      //AFTER: CLEAR DB
      beerRef.collection('expert_reviews').doc(expertReviewMockID).delete();
      beerRef.delete();
    });

    test('get expert review when it is not available', () async {
      //GIVEN: A BEER WITHOUT EXPERT REVIEW
      DocumentReference beerRef= firestoreMock.collection('beers').doc(beerMockID);
      beerRef.set(beerMock);

      //WHEN: RETRIEVE REVIEW
      ExpertReviewBloc _bloc = ExpertReviewBloc.testConstructor(firestoreMock);
      Future<ExpertReview> futureExpertReview= _bloc.reviewStream.first;
      _bloc.retrieveReview(Beer.fromSnapshot(beerMock));
      String error;
      try{
        await futureExpertReview;
      } catch(e){
        error=e.toString();
      }

      //ASSERT: NOT FOUND ERROR
      expect(error, ExpertReviewBloc.notFoundError);


      //AFTER: CLEAR DB
      beerRef.delete();
    });

    test('dispose', () async {
      //GIVEN: AN EXPERT REVIEW FOR A BEER
      DocumentReference beerRef= firestoreMock.collection('beers').doc(beerMockID);
      beerRef.set(beerMock);
      beerRef.collection('expert_reviews').doc(expertReviewMockID).set(expertReviewMock);

      //WHEN: DISPOSING A STREAM
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      ExpertReviewBloc _bloc = ExpertReviewBloc.testConstructor(firestoreMock);
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.dispose();
      });
      Future<ExpertReview> futureExpertReview= _bloc.reviewStream.last;
      _bloc.retrieveReview(Beer.fromSnapshot(beerMock));
      completer.complete();
      ExpertReview expertReview = await futureExpertReview.timeout(Duration(seconds: 10));

      //ASSERT: EXPERT REVIEW IS FOUND && NO TIMEOUT EXCEPTIONS
      expect(expertReview.id,expertReviewMockID);

      //AFTER: CLEAR DB
      beerRef.collection('expert_reviews').doc(expertReviewMockID).delete();
      beerRef.delete();
    });
  });
}
