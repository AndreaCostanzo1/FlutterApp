import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beertastic/blocs/expert_review_bloc.dart';
import 'package:flutter_beertastic/model/beer.dart';
import 'package:flutter_beertastic/model/expert_review.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpertReviewPage extends StatefulWidget {
  ExpertReviewPage(this._beer, {Key key}) : super(key: key);
  final Beer _beer;

  @override
  _ExpertReviewPageState createState() => _ExpertReviewPageState();
}

class _ExpertReviewPageState extends State<ExpertReviewPage> {
  ScrollController _controller;
  double backgroundOpacity;
  ExpertReviewBloc _reviewBloc;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(accentColor: Colors.white.withOpacity(0.3)),
      child: Scaffold(
        body: StreamBuilder<ExpertReview>(
            stream: _reviewBloc.reviewStream,
            builder: (context, snapshot) {
              ExpertReview review = snapshot.data;
              return review != null
                  ? review.id == ''
                      ? Container(
                          child: Text('Article not found'),
                        )
                      : Stack(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Image(
                                image: NetworkImage(review.coverImage),
                                fit: BoxFit.cover,
                                colorBlendMode: BlendMode.darken,
                                color: Colors.transparent,
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
                                    height:
                                        MediaQuery.of(context).size.height * 0.5,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    child: Text(
                                      review.title,
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
                                      review.text,
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
                                  ...review.subsections
                                      .map((subsection) => Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
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
                                                    fontFamily:
                                                        'Montserrat Regular',
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
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(20),
                                                            child: Image.network(
                                                                subsection
                                                                    .image)),
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
                                          review.author,
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
                                      if (review.source != null)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                onTap: () =>
                                                    launch(review.source),
                                                child: Container(
                                                  height: 21.5,
                                                  child: AutoSizeText(
                                                    'Source here',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontFamily:
                                                            'Montserrat Regular',
                                                        color: Colors.white,
                                                        decoration: TextDecoration
                                                            .underline),
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
                        )
                  : Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Container(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
            }),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    backgroundOpacity = 0.5;
    _controller = ScrollController();
    _controller.addListener(() => _uponScroll());
    _reviewBloc = ExpertReviewBloc();
    _reviewBloc.retrieveReview(widget._beer);
  }

  @override
  void dispose() {
    _controller.dispose();
    _reviewBloc.dispose();
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
