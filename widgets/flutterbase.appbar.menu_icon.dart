
import 'package:flutter/material.dart';

class AppBarMenuIcon extends StatelessWidget {
  AppBarMenuIcon({this.visible, this.onTap});

  final bool visible;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
          child: Container(
            padding: EdgeInsets.only(left: 8.0, right: 16.0),
        child: Visibility(
          visible: visible,
          child: Icon(
            Icons.menu,
            size: 30,
            // key: Key(AppService.key.drawerOpen),
          ),
        ),
      ),
    );
  }
}
