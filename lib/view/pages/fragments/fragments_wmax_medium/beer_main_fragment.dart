import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_beertastic/blocs/beer_bloc.dart';

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
                style: Theme.of(context).textTheme.subtitle2,
              ),
              SizedBox(height: 10.0),
              _Rating(Provider.of<Beer>(context)),
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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width*0.9,
          maxHeight: MediaQuery.of(context).size.height*0.13,
          minHeight: MediaQuery.of(context).size.height*0.08,
        ),
        child: AutoSizeText(
          beerName,
          style: Theme.of(context).textTheme.headline6,
        ),
      ), //Text
    );
  }
}

class _Rating extends StatefulWidget {
  final Beer _beer;

  _Rating(this._beer);

  @override
  __RatingState createState() => __RatingState();

}

class __RatingState extends State<_Rating> {

  BeerBloc _beerBloc = BeerBloc();

  @override
  Widget build(BuildContext context) {
    Beer beer = Beer.fromBeer(Provider.of<Beer>(context));
    return GestureDetector(
      onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BeerReviewsPage(beer),
            ),
          ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            SizedBox(width: 4.0),
            StreamBuilder<Beer>(
              stream: _beerBloc.singleBeerStream,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data!=null?snapshot.data.rating.toString():'0.0',
                  style: Theme.of(context).textTheme.headline4,
                );
              }
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Icon(
                Icons.star,
                color: Theme.of(context).textTheme.headline4.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _beerBloc=BeerBloc();
    _beerBloc.observeSingleBeer(widget._beer.id);
  }

  @override
  void dispose() {
    super.dispose();
    _beerBloc.dispose();
  }
}

class _ButtonAndImageRow extends StatelessWidget {
  _ButtonAndImageRow();

  @override
  Widget build(BuildContext context) {
    Beer beer = Beer.fromBeer(Provider.of<Beer>(context));
    // TODO: implement build
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        FloatingActionButton(
          onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsPage(beer),
                ),
              ),
          backgroundColor: Theme.of(context).canvasColor,
          child: Icon(
            CustomIcons.beer,
            color: Theme.of(context).backgroundColor,
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:330.0,
            minHeight: 280.0,
            maxWidth: 220.0,
          ),
          child: StreamBuilder(
            stream: FirebaseStorage.instance
                .ref()
                .child(Provider.of<Beer>(context).beerImageUrl)
                .getDownloadURL()
                .asStream(),
            builder: (context, urlSnapshot) {
              return urlSnapshot.data != null
                  ? Image.network(urlSnapshot.data)
                  : Container(height: 10,);
            },
          ),
        )
      ],
    );
  }
}
