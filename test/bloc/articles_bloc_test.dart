import 'dart:async';

import 'package:flutter_beertastic/blocs/articles_bloc.dart';
import 'package:flutter_beertastic/model/article.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks/firebase_firestore_mock.dart';

void main(){

  String articleMockID= '113213131231231asdasf';
  Map<String,dynamic> articleMock = {
  'id': articleMockID,
  'show' : true,
  'title' : 'My title',
  'punchline' : 'My punchline',
  'text' : 'My text',
  'category' : 'My category',
  'author' : 'author',
  'coverImage' : 'coverImage',
  'source' : 'source',
  'subsections' : []
  };

  List<Map<String,dynamic>> articleMocks = [articleMock];
  FirebaseFirestoreMock firestoreMock = FirebaseFirestoreMock.fromResult(articleMocks);

  group('article bloc tests', () {
    test('get articles',() async {
      //GIVEN: AN ARTICLE IN DATABASE

      //WHEN: THE USER RETRIEVE ARTICLES
      ArticlesBloc _bloc =ArticlesBloc.testConstructor(firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.retrieveArticles();
      });
      Future<List<Article>> futureArticleList =_bloc.articlesController.first;
      completer.complete();
      List<Article> articleList = await futureArticleList;
      expect(articleList.length, articleMocks.length);
      expect(articleList.map((e) => e.id).contains(articleMockID), true);
    });

    test('dispose',() async {
      //GIVEN: AN ARTICLE BLOC
      ArticlesBloc _bloc =ArticlesBloc.testConstructor(firestoreMock);
      Future<Null> run;
      Completer<Null> completer = Completer();
      run = completer.future;
      Future.delayed(Duration(milliseconds: 100), () async {
        await run;
        _bloc.dispose();
      });
      Future<List<Article>> futureArticleList =_bloc.articlesController.last;
      _bloc.retrieveArticles();
      //WHEN: THE ARTICLE BLOC IS DISPOSED
      completer.complete();

      //ASSERT: THE RESULT IS RETRIEVED CORRECTLY WITHOUT TIMEOUT ERRORS
      //NOTICE: calling last on a stream send the result only after the stream
      //is closed
      List<Article> articleList = await futureArticleList.timeout(Duration(seconds: 10));
      expect(articleList.length, articleMocks.length);
      expect(articleList.map((e) => e.id).contains(articleMockID), true);
    });
  });
}