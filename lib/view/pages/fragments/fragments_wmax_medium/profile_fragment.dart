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
                  end: const FractionalOffset(0.2, 0.2),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
              ),
          child: Container(
            padding: EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 90,
                  width: 90,
                  margin: EdgeInsets.only(top: 11),
                  child: ClipOval(
                    child: Image(image: NetworkImage('https://images.unsplash.com/photo-1548560781-a7a07d9d33db?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=581&q=80'),fit: BoxFit.cover,),
                  ),
                ),
                Column(
                  //TODO: ADD NAME AND MAIL
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}