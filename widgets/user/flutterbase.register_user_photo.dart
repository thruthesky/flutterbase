
import 'package:flutter/material.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.defines.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.user.helper.dart';
import 'package:fluttercms/flutterbase/services/flutterbase.storage.service.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.button.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.image.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.space.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.text.dart';

class FlutterbaseRegisterUserPhoto extends StatefulWidget {
  FlutterbaseRegisterUserPhoto(
    this.user,
    {
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

class _FlutterbaseRegisterUserPhotoState extends State<FlutterbaseRegisterUserPhoto> {
  bool inDelete = false;
  @override
  Widget build(BuildContext context) {
    String url = fb.userDocument?.photoUrl;
    bool hasPhoto = url != null && url != DELETED_PHOTO;

    // print('hasPhoto: $hasPhoto, $url');
    return Column(
      children: <Widget>[
        hasPhoto
            ? ClipOval(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: FlutterbaseImage(url),
                ),
              )
            : Material(
                elevation: 4.0,
                shape: CircleBorder(),
                clipBehavior: Clip.hardEdge,
                color: Colors.blueAccent,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.person,
                      size: 128,
                      color: Colors.white,
                    )),
              ),
        FlutterbaseSpace(),
        if (!hasPhoto) T('Upload photo'),
        if (hasPhoto) ...[
          T('Change photo'),
          FlutterbaseButton(
            showSpinner: inDelete,
            onPressed: () async {
              /// 사진 삭제
              if (inDelete) return;
              setState(() => inDelete = true);
              try {
                await FlutterbaseStorage(widget.user).delete(url);
                await fb.profileUpdate({'photoUrl': DELETED_PHOTO}); // @see README
                setState(() {});
              } catch (e) {
                widget.onError(e);
                // AppService.alert(null, t(e));
              }

              setState(() => inDelete = false);
            },
            text: t('Delete Photo'),
          ),
        ],
      ],
    );
  }
}
