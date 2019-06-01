import 'package:flutter/material.dart';

class CustomBackgroundedIconButton extends StatefulWidget {
  final Radius topLeftRadius;
  final Radius topRightRadius;
  final Radius bottomLeftRadius;
  final Radius bottomRightRadius;
  final Color backgroundColor;
  final Color outlineColor;
  final Color pressedColor;

  CustomBackgroundedIconButton({
    this.backgroundColor=const Color(0xff2c2731),
    this.outlineColor=Colors.white,
    this.pressedColor=const Color(0xff4e4954),
    this.topLeftRadius = Radius.zero,
    this.topRightRadius = Radius.zero,
    this.bottomLeftRadius = Radius.zero,
    this.bottomRightRadius = Radius.zero,
  });


  State<StatefulWidget> createState() => _ButtonState();
}

class _ButtonState extends State<CustomBackgroundedIconButton> {

  bool pressed=false;

  doSomething(TapDownDetails details){ //fix function name
    setState(() {
      pressed=true;
    });
  }

  doSomethingElse(TapUpDetails details){ //fix function name
    setState(() {
      pressed=false;
    });
  }

  doSomethingElse2(LongPressEndDetails details){ //fix function name
    setState(() {
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
      onLongPressEnd: (details)=>doSomethingElse2(details),
      child: AnimatedContainer(
        height: 80.0,
        duration: Duration(seconds: 1),
        width: MediaQuery.of(context).size.width / 2,
        curve: Curves.fastLinearToSlowEaseIn,
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
