
import 'package:flutter/material.dart';

class AppBarMenuIcon extends StatelessWidget {
  AppBarMenuIcon({this.visible, this.onTap});

  final bool visible;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.0,
      child: Visibility(
        visible: visible,
        child: FlatButton(
          child: Icon(
            Icons.menu,
            size: 30,
            color: Colors.white,
            // key: Key(AppService.key.drawerOpen),
          ),
          onPressed: onTap,
        ),
      ),
    );
  }
}
