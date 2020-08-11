import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beertastic/model/article.dart';

class ArticlePage extends StatefulWidget {
  ArticlePage(this.article, {Key key})
      : super(key: key);
  final Article article;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  ScrollController _controller;
  double backgroundOpacity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Hero(
              tag: widget.article.id,
              child: Image(
                image: NetworkImage(widget.article.coverImage),
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.darken,
                color: Colors.transparent,
              ),
            ),
          ),
          AnimatedContainer(
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                begin: const FractionalOffset(0.5, 0.5),
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.black.withOpacity(backgroundOpacity),
                  Color(0xCC000000),
                ],
                stops: [0.0, 1.0],
              ),
            ),
            duration: Duration(milliseconds: 700),
            curve: Curves.decelerate,
          ),
          ListView(
            controller: _controller,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    height: 26,
                    width: 90,
                    //get category box
                    child: _ArticleCategoryRender()
                        .getRenderedCategory(widget.article.category),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  widget.article.title,
                  style: TextStyle(
                      fontSize: 32,
                      fontFamily: 'Canvas Bold',
                      color: Colors.white),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.article.text,
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Montserrat Regular',
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    backgroundOpacity = 0.5;
    _controller = ScrollController();
    _controller.addListener(() => _uponScroll());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _uponScroll() {
    if (_controller.offset <= 30) {
      setState(() => backgroundOpacity = 0.5 + (_controller.offset) / 300);
    } else if (_controller.offset > 30 && _controller.offset <= 100) {
      setState(() => backgroundOpacity = 0.6);
    } else {
      setState(() => backgroundOpacity = 0.7);
    }
  }
}

class _ArticleCategoryRender {
  final Map<String, Widget> categoryRender = Map();

  Widget getRenderedCategory(String category) {
    return categoryRender[category] ?? Container();
  }

  final Widget _curiosity = Container(
    child: Center(
      child: Text(
        'CURIOSITY',
        style: TextStyle(
            color: Colors.white, fontSize: 14, fontFamily: 'Open Sans Bold'),
      ),
    ),
    decoration: BoxDecoration(
        gradient: new LinearGradient(
            colors: [
              Color(0xffc4001d),
              Color(0xFFFF6F00),
            ],
            begin: const FractionalOffset(1.0, 1.0),
            end: const FractionalOffset(0.2, 0.2),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
        borderRadius: BorderRadius.circular(5)),
  );
}
