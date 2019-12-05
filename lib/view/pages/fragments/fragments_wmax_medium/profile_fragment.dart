import 'package:flutter/material.dart';

class ProfileFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _ProfileSection(),
          //TODO: INSERT ELEMENT SUCK AS TICKET LABEL, etc.
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          constraints: BoxConstraints.expand(height: 175),
          decoration: BoxDecoration(
              gradient: new LinearGradient(
                  colors: [
                    Theme.of(context).primaryColorLight,
                    Theme.of(context).primaryColorDark
                  ],
                  begin: const FractionalOffset(1.0, 1.0),
                  end: const FractionalOffset(0.1, 0.1),
                  stops: [0.0, 0.8],
                  tileMode: TileMode.clamp),
              ),
          child: Container(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 95,
                  width: 95,
                  margin: EdgeInsets.only(top: 11),
                  child: ClipOval(
                    child: Image(image: NetworkImage('https://images.unsplash.com/photo-1548560781-a7a07d9d33db?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=581&q=80'),fit: BoxFit.cover,),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Andrea Costanzo"),
                      Text("andrea.costanzo96@gmail.com")
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}