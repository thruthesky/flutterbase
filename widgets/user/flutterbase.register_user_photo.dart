import 'package:flutter/material.dart';
import '../../etc/flutterbase.defines.dart';
import '../../etc/flutterbase.globals.dart';
import '../../etc/flutterbase.user.helper.dart';
import '../../services/flutterbase.storage.service.dart';
import '../../widgets/flutterbase.circle.dart';
import '../../widgets/flutterbase.image.dart';

///
///
/// 주의: 상단 위젯에 클릭 핸들러가 있다. 여기서는 삭제 아이콘만 클릭 이벤트 처리하면 된다.
class FlutterbaseRegisterUserPhoto extends StatefulWidget {
  FlutterbaseRegisterUserPhoto(
    this.user, {
    @required this.onError,
    Key key,
  }) : super(key: key);

  /// 사진 삭제를 하는 루틴과 호환을 위해서
  final FlutterbaseUser user;
  final Function onError;

  @override
  _FlutterbaseRegisterUserPhotoState createState() =>
      _FlutterbaseRegisterUserPhotoState();
}

class _FlutterbaseRegisterUserPhotoState
    extends State<FlutterbaseRegisterUserPhoto> {
  bool inDelete = false;
  @override
  Widget build(BuildContext context) {
    String url = fb.user?.photoUrl;
    bool hasPhoto = url != null && url != DELETED_PHOTO;

    // print('hasPhoto: $hasPhoto, $url');
    return Stack(
      children: <Widget>[
        hasPhoto
            ? UploadUserPhoto(url: url)
            : FlutterbaseCircle(
                child: Icon(
                  Icons.person,
                  size: 128,
                  color: Theme.of(context).backgroundColor,
                ),
                color: Theme.of(context).accentColor,
              ),
        Positioned(
          width: 40,
          height: 40,
          bottom: 0,
          child: FlutterbaseCircle(
            child: Icon(Icons.photo_camera),
          ),
        ),
        if ( hasPhoto ) Positioned(
          width: 40,
          height: 40,
          right: 0,
          bottom: 0,
          child: FlutterbaseCircle(
            showSpinner: inDelete,
            child: Icon(
              Icons.delete,
              color: Theme.of(context).accentColor,
            ),
            color: Theme.of(context).backgroundColor,
            onTap: () async {
              /// 사진 삭제
              setState(() => inDelete = true);
              try {
                await FlutterbaseStorage(widget.user).delete(url);
                await fb
                    .profileUpdate({'photoUrl': DELETED_PHOTO}); // @see README
                setState(() {});
              } catch (e) {
                widget.onError(e);
              }
              setState(() => inDelete = false);
            },
          ),
        ),
      ],
    );
  }
}

class UploadUserPhoto extends StatelessWidget {
  const UploadUserPhoto({
    Key key,
    @required this.url,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 200,
        height: 200,
        child: FlutterbaseImage(url),
      ),
    );
  }
}
