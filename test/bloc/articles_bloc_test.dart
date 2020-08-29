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

  FirebaseFirestoreMock firestoreMock = FirebaseFirestoreMock.fromResult([articleMock]);

    test('get articles',() async {
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
      expect(articleList.length, 1);
      expect(articleList[0].id, articleMockID);
    });
}