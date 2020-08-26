import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beertastic/blocs/authenticator.dart';
import 'package:flutter_beertastic/blocs/user_bloc.dart';
import 'package:flutter_beertastic/model/user.dart';
import 'package:flutter_beertastic/view/components/buttons/custom_profile_list_item.dart';
import 'package:flutter_beertastic/view/pages/styles/wmax_medium/profile_fragment_style.dart';
import 'package:flutter_beertastic/view/pages/settings_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../favourites_page.dart';

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
  UserBloc _profileBloc;

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
                              onTap: () => _changeImage(),
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
              StreamBuilder<MyUser>(
                  stream: _profileBloc.authenticatedUserStream,
                  builder: (context, snapshot) {
                    return snapshot.data != null
                        ? Column(
                            children: <Widget>[
                              Text(
                                snapshot.data.nickname,
                                style: titleTextStyle,
                              ),
                              SizedBox(height: SpacingUnit.w * 0.5),
                              Text(
                                snapshot.data.email,
                                style: captionTextStyle,
                              ),
                            ],
                          )
                        : Container(
                            height: SpacingUnit.w * 2,
                          );
                  }),
              SizedBox(height: SpacingUnit.w * 2),
              Material(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(SpacingUnit.w * 3),
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavouritesPage(),
                      )),
                  borderRadius: BorderRadius.circular(SpacingUnit.w * 3),
                  child: Container(
                    height: SpacingUnit.w * 4,
                    width: SpacingUnit.w * 20,
                    child: Center(
                      child: Text(
                        'My Favourites',
                        style: buttonTextStyle,
                      ),
                    ),
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
    _profileBloc = UserBloc();
    _profileBloc.getAuthenticatedUserData();
  }

  @override
  void dispose() {
    super.dispose();
    _profileBloc.dispose();
  }

  _changeImage() async {
    String string = await _profileBloc.getProfileImagePath();
    try {
      bool uploaded = await MethodChannel('PICKER_CHANNEL')
          .invokeMethod('STORAGE', Map.from({'path': string}));
      if (uploaded) _profileBloc.getAuthenticatedUserData();
    } catch (error) {
      //TODO: show upload failed
    }
  }
}

class _ProfileItems extends StatefulWidget {
  @override
  __ProfileItemsState createState() => __ProfileItemsState();
}

class __ProfileItemsState extends State<_ProfileItems> {
  AuthenticatorInterface _authBLoC;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authBLoC.remoteError,
      builder: (context, snapshot) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(snapshot.data!=null&&snapshot.data==RemoteError.REQUIRES_RECENT_LOGIN){
            showDialog(context: context,builder: (_)=>AlertDialog(
              title: Text('Attention'),
              content:
              Text('This operation requires recent login. You will be redirected to login page'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _authBLoC.logOut();
                  },
                  child: Text('Ok'),
                ),
              ],
            ));
          }
        });
        return Expanded(
          child: ScrollConfiguration(
            behavior: _HideGlowBehaviour(),
            child: ListView(
              children: <Widget>[
                ProfileListItem(
                  icon: LineAwesomeIcons.cog,
                  text: 'Settings',
                  color: Theme.of(context).backgroundColor,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(),
                      )),
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.alternate_sign_out,
                  text: 'Logout',
                  color: Theme.of(context).backgroundColor,
                  onTap: () => _authBLoC.logOut(),
                  hasNavigation: false,
                ),
                ProfileListItem(
                  icon: Icons.delete_forever,
                  text: 'Delete account',
                  color: Theme.of(context).backgroundColor,
                  onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            title: Text('Delete account?'),
                            content:
                                Text('Attention: this process is irreversible'),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _authBLoC.deleteAccount();
                                } ,
                                child: Text('Yes'),
                              ),
                              FlatButton(
                                onPressed: () =>Navigator.pop(context),
                                child: Text('No'),
                              ),
                            ],
                          ),
                      barrierDismissible: false),
                  hasNavigation: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _authBLoC=Authenticator();
  }

  @override
  void dispose() {
    super.dispose();
    _authBLoC.dispose();
  }
}

class _HideGlowBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
