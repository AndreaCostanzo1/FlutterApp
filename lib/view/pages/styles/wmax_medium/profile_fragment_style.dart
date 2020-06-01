import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const SpacingUnit = 10;

const DarkPrimaryColor = Color(0xFF212121);
const DarkSecondaryColor = Color(0xFF373737);
const LightPrimaryColor = Color(0xFFFFFFFF);
const LightSecondaryColor = Color(0xFFF3F7FB);
const AccentColor = Color(0xFFFFC107);


final titleTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(SpacingUnit.w * 1.7),
  fontWeight: FontWeight.w600,
  fontFamily: 'Open Sans SemiBold',
);

final captionTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(SpacingUnit.w * 1.3),
  fontWeight: FontWeight.w100,
  fontFamily: 'Open Sans Regular',
);

final buttonTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(SpacingUnit.w * 1.5),
  fontWeight: FontWeight.w400,
  fontFamily: 'Open Sans SemiBold',
  color: DarkPrimaryColor,
);


final lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Open Sans SemiBold',
  primaryColor: LightPrimaryColor,
  canvasColor: LightPrimaryColor,
  backgroundColor: LightSecondaryColor,
  accentColor: AccentColor,
  iconTheme: ThemeData.light().iconTheme.copyWith(
    color: DarkSecondaryColor,
  ),
  textTheme: ThemeData.light().textTheme.apply(
    fontFamily: 'Open Sans SemiBold',
    bodyColor: DarkSecondaryColor,
    displayColor: DarkSecondaryColor,
  ),
);