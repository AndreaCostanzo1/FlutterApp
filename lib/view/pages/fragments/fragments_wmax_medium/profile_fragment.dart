import 'package:flutter/material.dart';
import 'package:flutter_beertastic/blocs/authenticator.dart';
import 'package:flutter_beertastic/blocs/beer_bloc.dart';
import 'package:flutter_beertastic/blocs/profile_image_bloc.dart';
import 'package:flutter_beertastic/view/components/buttons/custom_profile_list_item.dart';
import 'package:flutter_beertastic/view/pages/styles/wmax_medium/profile_fragment_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class ProfileFragment extends StatefulWidget {
  @override
  _ProfileFragmentState createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: 896, width: 414, allowFontScaling: true);
    return Container(
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
      child: Column(
        children: <Widget>[
          SizedBox(height: SpacingUnit.w * 3),
          _ProfileSection(),
          _ProfileItems(),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatefulWidget {
  @override
  __ProfileSectionState createState() => __ProfileSectionState();
}

class __ProfileSectionState extends State<_ProfileSection> {
  ProfileImageBloc _profileBloc;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                height: SpacingUnit.w * 10,
                width: SpacingUnit.w * 10,
                margin: EdgeInsets.only(top: SpacingUnit.w * 3),
                child: Stack(
                  children: <Widget>[
                    StreamBuilder<ImageProvider>(
                        stream: _profileBloc.profileImageStream,
                        builder: (context, snapshot) {
                          return CircleAvatar(
                            radius: SpacingUnit.w * 5,
                            foregroundColor: Colors.grey,
                            backgroundImage: snapshot.data != null
                                ? snapshot.data
                                : AssetImage('assets/images/user.png'),
                          );
                        }),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ClipOval(
                        child: Material(
                          color: Theme.of(context).accentColor,
                          child: Container(
                            height: SpacingUnit.w * 2.5,
                            width: SpacingUnit.w * 2.5,
                            child: InkWell(
                              onTap: ()=> print('tap'),
                              child: Center(
                                heightFactor: SpacingUnit.w * 1.5,
                                widthFactor: SpacingUnit.w * 1.5,
                                child: Icon(
                                  LineAwesomeIcons.pen,
                                  color: DarkPrimaryColor,
                                  size: ScreenUtil().setSp(SpacingUnit.w * 1.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: SpacingUnit.w * 2),
              Text(
                'Mario Rossi',
                style: titleTextStyle,
              ),
              SizedBox(height: SpacingUnit.w * 0.5),
              Text(
                'mymail.address@gmail.com',
                style: captionTextStyle,
              ),
              SizedBox(height: SpacingUnit.w * 2),
              Container(
                height: SpacingUnit.w * 4,
                width: SpacingUnit.w * 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SpacingUnit.w * 3),
                  color: Theme.of(context).accentColor,
                ),
                child: Center(
                  child: Text(
                    'Main Button',
                    style: buttonTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileImageBloc();
    _profileBloc.getProfileImage();
  }

  @override
  void dispose() {
    super.dispose();
    _profileBloc.dispose();
  }
}

class _ProfileItems extends StatelessWidget {
  final AuthenticatorInterface _authBLoC = Authenticator();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authBLoC.remoteError,
      builder: (context, snapshot) {
        //TODO: Manage errors (see login_form line 31)
        return Expanded(
          child: ScrollConfiguration(
            behavior: _HideGlowBehaviour(),
            child: ListView(
              children: <Widget>[
                ProfileListItem(
                  icon: LineAwesomeIcons.cog,
                  text: 'Settings',
                  color: Theme.of(context).backgroundColor,
                  onTap: () => print('tap'),
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.alternate_sign_out,
                  text: 'Logout',
                  color: Theme.of(context).backgroundColor,
                  onTap: () => _authBLoC.logOut(),
                  hasNavigation: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HideGlowBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
