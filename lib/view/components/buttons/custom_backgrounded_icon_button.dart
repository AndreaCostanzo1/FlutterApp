import 'package:flutter/material.dart';
import 'dart:math';

class CustomBackgroundedIconButton extends StatefulWidget {
  final Radius topLeftRadius;
  final Radius topRightRadius;
  final Radius bottomLeftRadius;
  final Radius bottomRightRadius;
  final Color backgroundColor;
  final Color outlineColor;
  final Color pressedColor;
  final double buttonHeight;

  CustomBackgroundedIconButton({
    this.backgroundColor=const Color(0xff2c2731),
    this.outlineColor=Colors.white,
    this.pressedColor=const Color(0xff4e4954),
    this.topLeftRadius = Radius.zero,
    this.topRightRadius = Radius.zero,
    this.bottomLeftRadius = Radius.zero,
    this.bottomRightRadius = Radius.zero,
    this.buttonHeight= 80.0
  });


  State<StatefulWidget> createState() => _ButtonState();
}

class _ButtonState extends State<CustomBackgroundedIconButton> {

  bool pressed=false;
  Offset position;


  doSomething(TapDownDetails details){ //fix function name
    setState(() {
      position=details.globalPosition;
      pressed=true;
    });
  }

  doSomethingElse(TapUpDetails details){ //fix function name
    setState(() {
      pressed=false;
    });
  }

  doSomethingElse2(LongPressEndDetails details, BuildContext context){ //fix function name
    setState(() {
      double minX= (MediaQuery.of(context).size.width/2)+5;
      double minY= MediaQuery.of(context).size.height-widget.buttonHeight+5;
      var a = details.globalPosition.dx;
      if(details.globalPosition.dx>minX&&details.globalPosition.dy>minY) print('$minX, $a'); //fixme
      pressed=false;
    });
  }
  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    if(!pressed){
      backgroundColor=widget.backgroundColor;
    } else {
      backgroundColor=widget.pressedColor;
    }
    return GestureDetector(
      onTap: () => print('tap'), //fixme
      onTapDown: (details) => doSomething(details),
      onTapUp: (details) => doSomethingElse(details),
      onLongPressEnd: (details)=>doSomethingElse2(details,context),
      child: AnimatedContainer(
        height: widget.buttonHeight,
        duration: Duration(milliseconds: 300),
        width: MediaQuery.of(context).size.width / 2,
        curve: Curves.ease,
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius:
            BorderRadius.only(topLeft: widget.topLeftRadius,topRight: widget.topRightRadius,bottomLeft: widget.bottomLeftRadius,bottomRight: widget.bottomRightRadius)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.favorite,
              color: widget.outlineColor,
            ),
            SizedBox(
              width: 6.0,
            ),
            Text(
              'add to favorites',
              style: TextStyle(color: widget.outlineColor),
            )
          ],
        ),
      ),
    );
  }
}
