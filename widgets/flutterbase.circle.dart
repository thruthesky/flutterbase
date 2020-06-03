import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class FlutterbaseCircle extends StatelessWidget {
  FlutterbaseCircle({
    this.child,
    this.color,
    this.elevation = 4.0,
    this.clipBehavior = Clip.hardEdge,
    this.padding = const EdgeInsets.all(8.0),
    this.onTap,
    this.showSpinner = false,
  });

  final Widget child;
  final Color color;
  final double elevation;
  final Clip clipBehavior;
  final EdgeInsets padding;

  /// 이 값에 함수가 들어오면 터치가 발생 할 때, 함 수가 호출 된다.
  final Function onTap;

  /// [showSpinner] 가 true 이면,
  /// - [child] 대신 spinner 를 보여준다.
  /// - 터치가 안된다. [onTap] 함수가 더 이상 실행 되지 않는다.
  /// 따라서, 전송중 표시 를 할 때 좋다.
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    // if ( showSpinner ) return PlatformCircularProgressIndicator();

    Widget icon = Material(
      elevation: elevation,
      shape: CircleBorder(),
      clipBehavior: clipBehavior,
      color: color,
      child: Padding(
        padding: padding,
        child: showSpinner ? PlatformCircularProgressIndicator() : child,
      ),
    );
    if (onTap == null || showSpinner) return icon;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: icon,
      onTap: onTap,
    );
  }
}
