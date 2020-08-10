import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _EventDetailsBackground(),
          _EventDetailsContent(),
        ],
      ),
    );
  }
}

class _EventDetailsBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: Alignment.topCenter,
      child: ClipPath(
        clipper: ImageClipper(),
        child: Image.network(
          data[0]['image'],
          fit: BoxFit.cover,
          width: screenWidth,
          color: Color(0x99000000),
          colorBlendMode: BlendMode.darken,
          height: screenHeight * 0.52,
        ),
      ),
    );
  }
}

class ImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    Offset curveStartingPoint = Offset(0, 40);
    Offset curveEndPoint = Offset(size.width, size.height * 0.95);
    path.lineTo(curveStartingPoint.dx, curveStartingPoint.dy - 5);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.85,
        curveEndPoint.dx - 60, curveEndPoint.dy + 10);
    path.quadraticBezierTo(size.width * 0.97, size.height * 0.999,
        curveEndPoint.dx, curveEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class _EventDetailsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final event = events[0]; //FIXME delete me
    final _screenWidth = MediaQuery.of(context).size.width;
    final _screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: _screenWidth * 0.005),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: _screenHeight * 0.370,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: _screenHeight * 0.185,
                    margin: EdgeInsets.only(
                        left: _screenWidth * 0.285, right: _screenWidth * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AutoSizeText(
                          event.title,
                          style: eventWhiteTitleTextStyle,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: _screenWidth * 0.14),
                    margin: EdgeInsets.only(left: _screenWidth * 0.151),
                    child: FittedBox(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.trending_flat,
                            color: Colors.white,
                            size: 24,
                          ),
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            event.location,
                            style: eventLocationTextStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: _screenHeight*0.055,),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                "AWARDS",
                style: guestTextStyle,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  for (final guest in guests)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: ClipOval(
                        child: Image.network(
                          guest.imagePath,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: event.punchLine1,
                    style: punchLine1TextStyle,
                  ),
                  TextSpan(text: ' ',style: punchLine1TextStyle),
                  TextSpan(
                    text: event.punchLine2,
                    style: punchLine2TextStyle,
                  ),
                ]),
              ),
            ),
            if (event.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  event.description,
                  style: eventLocationTextStyle,
                ),
              ),
            if (event.galleryImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16, bottom: 16),
                child: Text(
                  "GALLERY",
                  style: guestTextStyle,
                ),
              ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  for (final galleryImagePath in event.galleryImages)
                    Container(
                      margin: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 32),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: Image.network(
                          //FIXME use async
                          galleryImagePath,
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//FIXME delete me
class Event {
  final String imagePath,
      title,
      description,
      location,
      duration,
      punchLine1,
      punchLine2;
  final List categoryIds, galleryImages;

  Event(
      {this.imagePath,
      this.title,
      this.description,
      this.location,
      this.duration,
      this.punchLine1,
      this.punchLine2,
      this.categoryIds,
      this.galleryImages});
}

final fiveKmRunEvent = Event(
    imagePath: "assets/event_images/5_km_downtown_run.jpeg",
    title: "Compleanno Birrificio di Lambrate",
    description: "",
    location: "Birrificio di Lambrate",
    duration: "3h",
    punchLine1: "Oggi",
    punchLine2: "faremo lorem e altre parole",
    galleryImages: [],
    categoryIds: [0, 1]);

final cookingEvent = Event(
    imagePath: "assets/event_images/granite_cooking_class.jpeg",
    title: "Granite Cooking Class",
    description:
        "Guest list fill up fast so be sure to apply before handto secure a spot.",
    location: "Food Court Avenue",
    duration: "4h",
    punchLine1: "Granite Cooking",
    punchLine2: "The latest fad in foodology, get the inside scoup.",
    categoryIds: [
      0,
      2
    ],
    galleryImages: [
      "assets/event_images/cooking_1.jpeg",
      "assets/event_images/cooking_2.jpeg",
      "assets/event_images/cooking_3.jpeg"
    ]);

final musicConcert = Event(
    imagePath: "assets/event_images/music_concert.jpeg",
    title: "Arijit Music Concert",
    description: "Listen to Arijit's latest compositions.",
    location: "D.Y. Patil Stadium, Mumbai",
    duration: "5h",
    punchLine1: "Music Lovers!",
    punchLine2: "The latest fad in foodology, get the inside scoup.",
    galleryImages: [
      "assets/event_images/cooking_1.jpeg",
      "assets/event_images/cooking_2.jpeg",
      "assets/event_images/cooking_3.jpeg"
    ],
    categoryIds: [
      0,
      1
    ]);

final golfCompetition = Event(
    imagePath: "assets/event_images/golf_competition.jpeg",
    title: "Season 2 Golf Estate",
    description: "",
    location: "NSIC Ground, Okhla",
    duration: "1d",
    punchLine1: "Golf!",
    punchLine2: "The latest fad in foodology, get the inside scoup.",
    galleryImages: [
      "assets/event_images/cooking_1.jpeg",
      "assets/event_images/cooking_2.jpeg",
      "assets/event_images/cooking_3.jpeg"
    ],
    categoryIds: [
      0,
      3
    ]);

final events = [
  fiveKmRunEvent,
  cookingEvent,
  musicConcert,
  golfCompetition,
];

//FIXME delete me
class Guest {
  final String imagePath;

  Guest(this.imagePath);
}

final guests = [
  Guest(data[1]['image']),
  Guest(data[1]['image']),
];

//FIXME: MOVE THESE STYLES AWAY
final TextStyle fadedTextStyle = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.bold,
  color: Color(0x99FFFFFF),
);

final TextStyle whiteHeadingTextStyle = TextStyle(
  fontSize: 40.0,
  fontWeight: FontWeight.bold,
  color: Color(0xFFFFFFFF),
);

final TextStyle categoryTextStyle = TextStyle(
  fontSize: 14.0,
  fontWeight: FontWeight.bold,
  color: Color(0xFFFFFFFF),
);

final TextStyle selectedCategoryTextStyle = categoryTextStyle.copyWith(
  color: Color(0xFFFF4700),
);

const TextStyle eventTitleTextStyle = TextStyle(
  fontSize: 24.0,
  fontFamily: "Campton Bold",
  fontWeight: FontWeight.bold,
  color: Color(0xFF000000),
);

const TextStyle eventWhiteTitleTextStyle = TextStyle(
  fontSize: 40.0,
  fontFamily: "Campton Bold",
  color: Color(0xFFFFFFFF),
);

const TextStyle eventLocationTextStyle = TextStyle(
  fontSize: 24.0,
  fontFamily: "Campton Bold",
  color: Color(0xFF000000),
);

const TextStyle guestTextStyle = TextStyle(
  fontSize: 18.0,
  fontFamily: "Campton Bold",
  fontWeight: FontWeight.w800,
  color: Color(0xFF000000),
);

const TextStyle punchLine1TextStyle = TextStyle(
  fontSize: 28.0,
  fontFamily: "Campton Bold",
  fontWeight: FontWeight.w800,
  color: Color(0xFFFF4700),
);

const TextStyle punchLine2TextStyle = TextStyle(
  fontSize: 28.0,
  fontFamily: "Campton Bold",
  fontWeight: FontWeight.w800,
  color: Color(0xFF000000),
);

//FIXME CANCEL ME
List data = [
  {
    'name': 'Antelope Canyon',
    'image':
        'https://images.unsplash.com/photo-1527498913931-c302284a62af?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=934&q=80',
    'description':
        'Over the years, Lover Antelope Canyon has become a favorite gathering pace for photographers tourists, and visitors from the world.',
    'date': 'Mar 20, 2019',
    'rating': '4.7',
    'cost': '\$40.00'
  },
  {
    'name': 'Genteng Lembang',
    'image':
        'https://images.unsplash.com/photo-1548560781-a7a07d9d33db?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=581&q=80',
    'description':
        'Over the years, Lover Antelope Canyon has become a favorite gathering pace for photographers tourists, and visitors from the world.',
    'date': 'Mar 24, 2019',
    'rating': '4,83',
    'cost': '\$50.00'
  },
  {
    'name': 'Kamchatka Peninsula',
    'image':
        'https://images.unsplash.com/photo-1542869781-a272dedbc93e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=983&q=80',
    'description':
        'Over the years, Lover Antelope Canyon has become a favorite gathering pace for photographers tourists, and visitors from the world.',
    'date': 'Apr 18, 2019',
    'rating': '4,7',
    'cost': '\$30.00'
  },
];
