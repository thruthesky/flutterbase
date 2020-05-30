
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.space.dart';

class FlutterbaseButton extends StatelessWidget {
  FlutterbaseButton({
    this.loader,
    this.text,
    this.onPressed,
  });

  /// [loader] 가 참이면, spinner 를 보여주고, 버튼을 disable 시킨다.
  final bool loader;
  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: loader ? null : onPressed,
      child: Row(
        children: <Widget>[
          if (loader) ...[
            PlatformCircularProgressIndicator(),
            FlutterbaseSpace(),
          ],
          Text(text),
        ],
      ),
    );
  }
}
