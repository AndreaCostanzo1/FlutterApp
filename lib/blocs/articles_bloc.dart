import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_beertastic/model/article.dart';

class ArticlesBloc {
  final List<Article> _articles = List<Article>();

  final List<StreamSubscription> _subscriptions = List<StreamSubscription>();

  //.broadcast used when there are multiple listeners
  final StreamController<List<Article>> _articlesController =
      StreamController<List<Article>>.broadcast();

  final StreamController<Article> _singleArticleController =
      StreamController<Article>.broadcast();

  Stream<List<Article>> get articlesController => _articlesController.stream;

  Stream<Article> get singleArticleController => _singleArticleController.stream;

  void dispose() async {
    _subscriptions.forEach((subscription) => subscription.cancel());
    _articlesController?.close();
    _singleArticleController?.close();
  }

  void retrieveArticles() {
    _subscriptions.add(Firestore.instance
        .collection('articles')
        .where('show', isEqualTo: true)
        .snapshots()
        .listen((query) => _updateArticlesSink(query.documents)));
  }

  _updateArticlesSink(List<DocumentSnapshot> okrSnapshots) {
    //get the list of articles still not retrieved
    _articles.addAll(okrSnapshots
        .map((snapshots) => Article.fromSnapshot(snapshots.data))
        .toList());
    _articlesController.sink.add(_articles);
  }
}
