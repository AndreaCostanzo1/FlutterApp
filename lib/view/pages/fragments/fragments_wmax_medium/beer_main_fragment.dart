import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter_beertastic/model/beer.dart';
import 'package:flutter_beertastic/view/components/icons/custom_icons.dart';
import 'package:flutter_beertastic/view/pages/beer_details_page.dart';
import 'package:flutter_beertastic/view/pages/beer_reviews_page.dart';

import 'package:provider/provider.dart';

class BeerMainFragmentMedium extends StatelessWidget {
  BeerMainFragmentMedium();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(108.0)),
          color: Theme.of(context).backgroundColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Title(Provider.of<Beer>(context).name),
              Text(
                Provider.of<Beer>(context).producer,
                style: Theme.of(context).textTheme.subtitle,
              ),
              SizedBox(height: 12.0),
              _Rating(Provider.of<Beer>(context).rating.toString()),
              Spacer(),
              _ButtonAndImageRow(),
              SizedBox(height: 16.0)
            ],
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String beerName;

  _Title(this.beerName);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
      width: 300.0,
      child: Text(
        beerName,
        style: Theme.of(context).textTheme.title,
      ), //Text
    );
  }
}

class _Rating extends StatelessWidget {
  final String rating;

  _Rating(this.rating);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BeerReviewsPage(),
            ),
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          SizedBox(width: 4.0),
          Text(
            rating,
            style: Theme.of(context).textTheme.display1,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Icon(
              Icons.star,
              color: Theme.of(context).textTheme.display1.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonAndImageRow extends StatelessWidget {
  _ButtonAndImageRow();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        FloatingActionButton(
          onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(),
                ),
              ),
          backgroundColor: Theme.of(context).canvasColor,
          child: Icon(
            CustomIcons.beer,
            color: Theme.of(context).backgroundColor,
          ),
        ),
        Container(
          width: 200.0,
          height: 330.0,
          child: StreamBuilder(
            stream: FirebaseStorage.instance
                .ref()
                .child(Provider.of<Beer>(context).beerImageUrl)
                .getDownloadURL()
                .asStream(),
            builder: (context, urlSnapshot) {
              return urlSnapshot.data != null
                  ? Image.network(urlSnapshot.data)
                  : Container();
            },
          ),
        )
      ],
    );
  }
}
