import 'package:flutter/material.dart';
import 'package:flutter_beertastic/view/pages/styles/wmax_medium/profile_fragment_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';


class ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool hasNavigation;
  final Function onTap;
  final Color color;

  const ProfileListItem({
    Key key,
    this.icon,
    this.text,
    this.color,
    this.onTap,
    this.hasNavigation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
      height: SpacingUnit.w * 5.5,
      margin: EdgeInsets.symmetric(
        horizontal: SpacingUnit.w * 4,
      ).copyWith(
        bottom: SpacingUnit.w * 2,
      ),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingUnit.w * 3),
        color: color,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SpacingUnit.w * 3),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SpacingUnit.w * 2,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  this.icon,
                  size: SpacingUnit.w * 2.5,
                ),
                SizedBox(width: SpacingUnit.w * 1.5),
                Text(
                  this.text,
                  style: titleTextStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                if (this.hasNavigation)
                  Icon(
                    LineAwesomeIcons.angle_right,
                    size: SpacingUnit.w * 2.5,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}