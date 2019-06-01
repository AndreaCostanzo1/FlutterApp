import 'package:flutter/material.dart';

Color bottomBarColor = Colors.amber[400];
Color bottomBarSquareColor = Colors.amber[600];

class BeerMainFragmentMedium extends StatelessWidget {
  final Color mainColor;
  final Color actionButtonColor;
  final Color textColor;
  final Color commentTextColor;
  final Map beer;

  BeerMainFragmentMedium(
    this.beer, {
    this.mainColor = Colors.white,
    this.actionButtonColor = Colors.amber,
    this.textColor = Colors.black,
    this.commentTextColor = Colors.black45,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(108.0)),
          color: mainColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Title(
                beer['name'],
                textColor,
              ),
              Text(
                beer['producer'],
                style: TextStyle(color: commentTextColor),
              ),
              SizedBox(height: 12.0),
              _Rating(
                beer['rating'],
                actionButtonColor,
              ),
              Spacer(),
              _ButtonAndImageRow(
                beer['image'],
                actionButtonColor,
              ),
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
  final Color textColor;

  _Title(
    this.beerName,
    this.textColor,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
      width: 300.0,
      child: Text(
        beerName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 48.0,
          color: textColor,
        ), //TextStyle
      ), //Text
    );
  }
}

class _Rating extends StatelessWidget {
  final String rating;
  final Color ratingColor;

  _Rating(this.rating, this.ratingColor);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        SizedBox(width: 4.0),
        Text(
          rating,
          style: TextStyle(
            color: ratingColor,
            fontWeight: FontWeight.bold,
            fontSize: 32.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Icon(
            Icons.star,
            color: ratingColor,
          ),
        ),
      ],
    );
  }
}

class _ButtonAndImageRow extends StatelessWidget {
  final String imageUrl;
  final Color actionButtonColor;

  _ButtonAndImageRow(
    this.imageUrl,
    this.actionButtonColor,
  );

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
          backgroundColor: actionButtonColor,
          child: Icon(Icons.local_bar),
        ),
        Container(
          width: 200.0,
          height: 330.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        )
      ],
    );
  }
}

class DetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bottomBarColor,
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('greenery nyc',
                    style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 1.1,
                        fontSize: 22.0)),
                SizedBox(height: 32.0),
                Container(
                  width: 200.0,
                  child: Text(
                    'Product Overview',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 48.0),
                  ),
                ),
                SizedBox(height: 42.0),
                itemRow(Icons.star, 'water', 'every 7 days'),
                SizedBox(height: 22.0),
                itemRow(Icons.ac_unit, 'Humidity', 'up to 82%'),
                SizedBox(height: 22.0),
                itemRow(Icons.straighten, 'Size', '38" - 48"tdll'),
              ],
            ),
          ),
          SizedBox(height: 32.0),
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: Container(
              height: 60.0,
              decoration: BoxDecoration(
                  color: bottomBarSquareColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32.0),
                      bottomLeft: Radius.circular(32.0))),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 20.0),
                  Icon(Icons.add, color: Colors.white, size: 24.0),
                  SizedBox(width: 40.0),
                  Text(
                    'Delivery Information',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 32.0),
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: Container(
              height: 60.0,
              decoration: BoxDecoration(
                  color: bottomBarSquareColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32.0),
                      bottomLeft: Radius.circular(32.0))),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 20.0),
                  Icon(Icons.add, color: Colors.white, size: 24.0),
                  SizedBox(width: 40.0),
                  Text(
                    'Return Policy',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
          Container(
            height: 80.0,
            child: Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                  ),
                ),
                Container(
                    height: 80.0,
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                        color: Color(0xff2c2731),
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(48.0))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 6.0,
                        ),
                        Text(
                          'add to cart',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }

  itemRow(icon, name, title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              icon,
              color: Colors.white,
            ),
            SizedBox(width: 6.0),
            Text(
              name,
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            )
          ],
        ),
        Text(title, style: TextStyle(color: Colors.white54, fontSize: 20.0))
      ],
    );
  }
}
