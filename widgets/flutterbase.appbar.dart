import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttercms/flutterbase/models/flutterbase.model.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.appbar.menu_icon.dart';
import 'package:fluttercms/flutterbase/widgets/user/flutterbase.user_photo.dart';
import 'package:provider/provider.dart';

/// `FlutterbaseAppBar` Widget
///
/// [title] is an empty string by default.
///
/// [elevation] is the z-index of the appbar.
///   if not specified and if the current platform is `IOS` it will automatically be set to `0.0`, and `1.0` for `Android`.
///
/// [centerTitle] is `true` by default. if [actions] is specified it will be automatically set to `false`.
///
/// [actions] can accept any widget, it is preferabble to use button widgets.
///   if this is specified and the current scaffold which this `FlutterbaseAppBar` widget belongs to have an `endDrawer`
///   it will show an internal `Menu` Button to open the drawer.
///
/// [backgroundColor] is for the app bar color.
///
/// [automaticallyImplyLeading] is `true` by default, if set to `false`, it will not display the back button when navigating.
///
///
class FlutterbaseAppBar extends StatelessWidget with PreferredSizeWidget {
  FlutterbaseAppBar({
    this.title = '',
    this.elevation,
    this.centerTitle = true,
    this.actions,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
    this.onPressedCreatePostButton,
    this.displayUserPhoto = true,
    @required this.onTapUserPhoto,
  });

  final String title;
  final bool centerTitle;
  final double elevation;
  final Widget actions;
  final Color backgroundColor;
  final bool automaticallyImplyLeading;
  final Function onPressedCreatePostButton;
  final bool displayUserPhoto;

  final Function onTapUserPhoto;

  _openAppDrawer(ScaffoldState scaffold) {
    if (scaffold.hasDrawer) {
      scaffold.openDrawer();
    } else if (scaffold.hasEndDrawer) {
      scaffold.openEndDrawer();
    } else {
      /// do nothing ...
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);

    return AppBar(
      title: Text(title),
      centerTitle: actions == null ? centerTitle : false,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: elevation == null ? Platform.isIOS ? 0.0 : 1.0 : elevation,
      backgroundColor: backgroundColor,
      actions: <Widget>[
        if (actions != null) actions,
        if (displayUserPhoto)
          Selector<FlutterbaseModel, String>(
            builder: (context, url, child) {
              return FlutterbaseUserPhoto(url, onTap: onTapUserPhoto);
            },
            selector: (_, model) => model.userDocument?.photoUrl,
          ),
        AppBarMenuIcon(
          visible: scaffold.hasEndDrawer,
          onTap: () => _openAppDrawer(scaffold),
        ),
      ],
    );
  }
}
