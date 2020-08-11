import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beertastic/model/article.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlePage extends StatefulWidget {
  ArticlePage(this.article, {Key key}) : super(key: key);
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
          Container(
            margin: EdgeInsets.symmetric(horizontal: 13),
            child: ListView(
              controller: _controller,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                ),
                _ArticleCategoryRender()
                    .getRenderedCategory(widget.article.category),
                SizedBox(
                  height: 10,
                ),
                Container(
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
                ),
                ...widget.article.subsections
                    .map((subsection) => Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                subsection.title,
                                style: TextStyle(
                                    fontSize: 26,
                                    fontFamily: 'Canvas Bold',
                                    color: Colors.white),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: Text(
                                subsection.text,
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
                            ),
                            subsection.image == null
                                ? Container()
                                : Column(
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(subsection.image)),
                                    SizedBox(
                                      height: 40,
                                    ),
                                  ],
                                ),
                          ],
                        ))
                    .toList(),
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        widget.article.author,
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Montserrat Regular',
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    if (widget.article.source != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => launch(widget.article.source),
                              child: Container(
                                height: 21.5,
                                child: AutoSizeText(
                                  'Source here',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Montserrat Regular',
                                      color: Colors.white,
                                      decoration: TextDecoration.underline),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
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
  final Map<String, Widget> categoryRender = Map.from({
    'curiosity': CuriosityTag(),
    'home brewing': HomeBrewingTag(),
  });

  Widget getRenderedCategory(String category) {
    return categoryRender[category] ?? Container();
  }
}

class CuriosityTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 26,
          width: 90,
          child: Center(
            child: Text(
              'CURIOSITY',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Open Sans Bold'),
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
        ),
      ],
    );
  }
}

class HomeBrewingTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 26,
          width: 130,
          child: Center(
            child: Text(
              'HOME BREWING',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Open Sans Bold'),
            ),
          ),
          decoration: BoxDecoration(
              gradient: new LinearGradient(
                  colors: [
                    Color(0xFF38ef7d),
                    Color(0xFF11998e),
                  ],
                  begin: const FractionalOffset(1.0, 1.0),
                  end: const FractionalOffset(0.2, 0.2),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
              borderRadius: BorderRadius.circular(5)),
        ),
      ],
    );
  }
}
