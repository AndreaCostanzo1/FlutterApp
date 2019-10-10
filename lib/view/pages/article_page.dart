import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ArticlePage extends StatefulWidget{
  ArticlePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}