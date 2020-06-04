
import 'package:flutter/material.dart';
import '../../etc/flutterbase.defines.dart';
import '../../etc/flutterbase.globals.dart';
import '../../widgets/flutterbase.image.dart';

class FlutterbaseUserPhoto extends StatelessWidget {
  const FlutterbaseUserPhoto(
    this.url, {
    this.onTap,
    Key key,
  }) : super(key: key);

  final String url;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    // print('FlutterbaseUserPhoto() url: $url');
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge,
          color: Colors.blueAccent,
          child: SizedBox(
            width: 44,
            height: 44,
            child: (isEmpty(url) ||
                    url == DELETED_PHOTO ||
                    /// 사진이 http 로 시작하는 문자열이 아니면, NetworkCacheImage 에서 부하 에러가 난다.
                    ///
                    url.indexOf('http') != 0)
                ? Image.asset('lib/flutterbase/assets/images/user-icon.png')
                : FlutterbaseImage(url),
          ),
        ),
      ),
    );
  }
}
