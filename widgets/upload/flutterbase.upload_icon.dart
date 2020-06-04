import 'dart:async';

import 'package:flutter/material.dart';
import '../../etc/flutterbase.globals.dart';
import '../../services/flutterbase.storage.service.dart';
import 'package:image_picker/image_picker.dart';

/// 업로드 아이콘을 표히사고 클릭을 하면 사진 업로드를 한다.
///
/// - 사진은 Firestore 에 등록하고
///   글, 코멘트, 사용자 도큐먼트의 [doc.urls] 에 URL 을 추가하는데 이것을 Document 에 바로 저장하면 된다.
///   참고로 사용자의 경우, 임시로 `urls` 속성을 두면 되고,
///   또는 어떤 객체라도 [urls] 속성이 있으면 된다. 그래서 임시로 { urls: [] } 와 같이 만들어 쓰면 된다.
/// 
/// - 사진 업로드 중에 percentage 는 [onProgress] 콜백으로 표시하고
///   사진 업로드가 완료되면 [onUpload] 콜백이 호출 된다.
/// 
/// - [icon] 에는 원하는 아이콘을 집어 넣으면 된다. 아이콘 뿐만아니라 원하는 위젯을 아무거나 넣으면 된다.
///   사용자 사진 등록시에는 아이콘(사진)과 문자열을 가지는 Column 을 [icon] 에 지정해도 된다.
///
/// - 사용자 사진 업로드를 할 때에는 회원 가입시에만 [doc.urls] 를 사용하고,
///   회원 사진 수정, 삭제를 할 때에는 [doc.urls] 을 거치지 않고 수정/삭제를 하면 곧 바로 `Enginf`를 통해서 저장해 버린다.
///
/// 참고로 [FlutterbaseUploadIcon] 에서 Percentage 를 [UploadProgressBar] 로 표시하고 업로드가 되면 [DisplayUploadedImages] 로 표시를 하면 된다.
///
///
/// ``` dart
/// FlutterbaseUploadIcon(widget.currentComment, (p) {
///   setState(() {
///     progress = p;
///   });
/// }, (String url) {
///   setState(() {});
/// })
/// ```
///

class FlutterbaseUploadIcon extends StatelessWidget {
  FlutterbaseUploadIcon(
    this.doc, {
    @required this.onProgress,
    @required this.onUploadComplete,
    @required this.onError,
    this.icon,
    Key key,
  }) : super(key: key) {
    
    if (doc.urls == null || !(doc.urls is List)) {
      Timer(Duration(milliseconds: 500),
          () => alert('doc.urls is not a List in FlutterbaseUploadIcon'));
    }
  }

  /// 사용자 도큐먼트 또는 글/코멘트 도큐먼트 등
  final doc;

  /// 업로드 성공시 콜백
  final Function onUploadComplete;

  /// 업로드 진행 콜백. Percentage 값을 알려 줌.
  final Function onProgress;
  final Function onError;

  final Widget icon;

  _back(context) {
    Navigator.pop(context);
  }

  upload(context, source) async {
    _back(context);
    // print('from camea');
    try {
      String url = await FlutterbaseStorage(doc).pickAndUploadImage(
        context,
        source,
        onUploadComplete: onUploadComplete,
        onUploadPercentage: onProgress,
      );

      // print('FlutterbaseUploadIcon:: camera: file uploaded: $url');
    } catch (e) {
      onError(e);
      // AppService.alert(null, t(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    var _icon = icon;
    if (icon == null) _icon = Icon(Icons.photo_camera);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: _icon,
      onTap: () {
        bottomSheet([
          {
            'icon': Icons.photo_camera,
            'text': t('Take photo from camera'),
            'onTap': () => upload(context, ImageSource.camera.index),
          },
          {
            'icon': Icons.photo_album,
            'text': t('Take photo from Gallary'),
            'onTap': () => upload(context, ImageSource.gallery.index),
          },
          {
            'icon': Icons.close,
            'text': t('cancel'),
            'onTap': () {
              _back(context);
            }
          },
        ]);
      },
    );
  }
}
