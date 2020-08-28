import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_beertastic/model/article.dart';

class ArticlesBloc {

  final FirebaseFirestore _firestore;

  final List<Article> _articles = List<Article>();

  final List<StreamSubscription> _subscriptions = List<StreamSubscription>();

  //.broadcast used when there are multiple listeners
  final StreamController<List<Article>> _articlesController =
      StreamController<List<Article>>.broadcast();

  Stream<List<Article>> get articlesController => _articlesController.stream;


  ArticlesBloc(): this._firestore = FirebaseFirestore.instance;

  ArticlesBloc.testConstructor(FirebaseFirestore firestore): this._firestore=firestore;

  void dispose() {
    _subscriptions.forEach((subscription) => subscription.cancel());
    _articlesController?.close();
  }

  void retrieveArticles() {
    _subscriptions.add(_firestore
        .collection('articles')
        .where('show', isEqualTo: true)
        .snapshots()
        .listen((query) => _updateArticlesSink(query.docs)));
  }

  _updateArticlesSink(List<DocumentSnapshot> articlesSnapshots) {
    //get the list of articles still not retrieved
    _articles.clear();
    _articles.addAll(articlesSnapshots
        .map((snapshots) => Article.fromSnapshot(snapshots.data()))
        .toList());
    _articlesController.sink.add(_articles);
  }
}
