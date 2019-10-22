import 'package:flutter/material.dart';

class CustomBackgroundedIconButton extends StatelessWidget {
  final Radius topLeftRadius;
  final Radius topRightRadius;
  final Radius bottomLeftRadius;
  final Radius bottomRightRadius;
  final Color backgroundColor;
  final Color outlineColor;
  final double buttonHeight;

  CustomBackgroundedIconButton(
      {this.backgroundColor = const Color(0xff2c2731),
        this.outlineColor = Colors.white,
        this.topLeftRadius = Radius.zero,
        this.topRightRadius = Radius.zero,
        this.bottomLeftRadius = Radius.zero,
        this.bottomRightRadius = Radius.zero,
        this.buttonHeight = 80.0});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: buttonHeight,
      duration: Duration(milliseconds: 300),
      width: MediaQuery.of(context).size.width / 2,
      curve: Curves.ease,
      decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
              topLeft: topLeftRadius,
              topRight: topRightRadius,
              bottomLeft: bottomLeftRadius,
              bottomRight: bottomRightRadius)),
      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.only(
              topLeft: topLeftRadius,
              topRight: topRightRadius,
              bottomLeft: bottomLeftRadius,
              bottomRight: bottomRightRadius),
          onTap: () => print('tap'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.favorite,
                color: outlineColor,
              ),
              SizedBox(
                width: 6.0,
              ),
              Text(
                'add to favorites',
                style: TextStyle(color: outlineColor),
              )
            ],
          ),
        ),
      ),
    );
  }
}
