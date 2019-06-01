import 'package:flutter/material.dart';

import 'package:flutter_beertastic/view/pages/beer_details_page.dart';
import 'package:flutter_beertastic/view/pages/beer_reviews_page.dart';

class BeerMainFragmentSmall extends StatelessWidget {
  final Map beer;

  BeerMainFragmentSmall(this.beer);

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
              _Title(beer['name']),
              Text(
                beer['producer'],
                style: Theme.of(context).textTheme.subtitle,
              ),
              SizedBox(height: 8.0),
              _Rating(beer['rating']),
              Spacer(),
              _ButtonAndImageRow(beer['image']),
              SizedBox(height: 8.0)
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
      width: 160.0,
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
          Text(rating, style: Theme.of(context).textTheme.display1),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Icon(
              Icons.star,
              color: Theme.of(context).textTheme.display1.color,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonAndImageRow extends StatelessWidget {
  final String imageUrl;

  _ButtonAndImageRow(
    this.imageUrl,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(
          width: 42.0,
          height: 42.0,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(),
                  ),
                ),
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(
              Icons.local_bar,
              size: 20,
              color: Theme.of(context).backgroundColor,
            ),
          ),
        ),
        Container(
          width: 160.0,
          height: 260.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        )
      ],
    );
  }
}
