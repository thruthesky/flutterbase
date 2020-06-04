
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../widgets/flutterbase.space.dart';

class FlutterbaseButton extends StatelessWidget {
  FlutterbaseButton({
    this.showSpinner,
    this.text,
    this.onPressed,
  });

  /// [loader] 가 참이면, spinner 를 보여주고, 버튼을 disable 시킨다.
  final bool showSpinner;
  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: showSpinner ? null : onPressed,
      child: Row(
        children: <Widget>[
          if (showSpinner) ...[
            PlatformCircularProgressIndicator(),
            FlutterbaseSpace(),
          ],
          Text(text),
        ],
      ),
    );
  }
}
