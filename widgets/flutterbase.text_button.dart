import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.space.dart';

/// FutterButton 과 비슷한데, 그냥 텍스트로 클릭이 되는 것이다.
class FlutterbaseTextButton extends StatelessWidget {
  FlutterbaseTextButton({
    this.showSpinner = false,
    this.padding = const EdgeInsets.all(8.0),
    this.text,
    this.onTap,
  });
  final bool showSpinner;
  final String text;
  final Function onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            if (showSpinner) ...[
              PlatformCircularProgressIndicator(),
              FlutterbaseHalfSpace(),
            ],
            Text(text),
          ],
        ),
      ),
    );
  }
}
