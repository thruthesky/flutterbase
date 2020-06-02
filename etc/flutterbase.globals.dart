import 'package:fluttercms/flutterbase/etc/flutterbase.app.localization.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.defines.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.texts.dart';

import '../widgets/flutterbase.text.dart';
import 'dart:math';

// import './widgets/engine.text.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

// import './engine.app.localization.dart';
// import './engine.error.helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/flutterbase.model.dart';

///
/// `Engine` 에서 사용하는 글로벌 변수 몽므

// import './engine.model.dart';

/// `Engine` `state model` 을 여기서 한번만 생성하여 글로벌 변수로 사용한다.
/// 글로벌 변수 명은 `ef` 이며, 이 값을 Provider 에 등록하면 되고, 필요하면 이 객체를 바로 사용하면 된다.
///
/// * 객체 생성은 main.dart 에서 하면 된다.
FlutterbaseModel fb = FlutterbaseModel();

// const String hiveCacheBox = 'cache';

/// Translate texts
///
/// Returns translated string from the text code.
/// If [code] is an `Error object`,
///   - It parses the Error and returns proper text translation.
String t(code, {info}) {
  if (code == null) return null;
  if (code is FlutterError) code = code.message;
  if (code is PlatformException) {
    String tmp = code.code + "\n" + code.message + "\n" + (code.details ?? '');

    if (tmp.indexOf('Error 7') != -1 ||
        tmp.indexOf('insufficient permissions') != -1) {
      code = PERMISSION_DENIED;
    } else
      code = tmp;
  }

  return AppLocalizations.of(fb.context).t(code, info: info);
}

/// App language code
/// @return two letter string
///   'ko' - Korean
///   'en' - English
///   'zh' - Chinese
///   'ja' - Japanese.
String appLanguageCode() {
  return AppLocalizations.of(fb.context).locale.languageCode;
}

bottomSheet(List<Map<String, dynamic>> items) {
  showModalBottomSheet(
    context: fb.context,
    builder: (BuildContext bc) {
      return SafeArea(
        child: Container(
          child: new Wrap(
            children: <Widget>[
              for (var item in items)
                new ListTile(
                  leading: new Icon(item['icon']),
                  title: new Text(item['text']),
                  onTap: item['onTap'],
                  // new ListTile(
                  //   leading: new Icon(Icons.videocam),
                  //   title: new Text('Video'),
                  //   onTap: () => {},
                ),
            ],
          ),
        ),
      );
    },
  );
}

void _back({arguments}) {
  Navigator.pop(fb.context, arguments);
}

/// Show alert box
/// @example AppService.alert(null, e.message);
// engineAlert(String title, { String content}) {
//   if ( content == null ) {
//     content = title;
//     title = null;
//   }
//   showPlatformDialog(
//     context: ef.context,
//     builder: (_) => PlatformAlertDialog(
//       title: title != null ? Text(title) : null,
//       content: Text(content),
//       actions: <Widget>[
//         PlatformDialogAction(
//           child: PlatformText(t('Ok')),
//           onPressed: () => Navigator.pop(ef.context),
//         ),
//       ],
//     ),
//   );
// }

/// Show alert box
/// @example async( onError: alert );
/// @example alert(e) - where `e` can be an Error Object.
alert(dynamic title, {String content}) {
  /// title 이 문자열이고,
  if (title is String) {
    /// textTranslations 에 존재 하는 것이면 t 한다.
    if (textTranslations[title] != null) {
      title = t(title);
    }
  } else {
    /// 제목이 문자열이 아니면, t() 한다.
    title = t(title);
  }

  /// content 가 문자열이고,
  if (content is String) {
    /// textTranslations 에 존재하면 t 한다.
    if (textTranslations[content] != null) {
      content = t(content);
    }
  } else {
    /// 내용이 문자열이 아니면, t() 한다.
    content = t(content);
  }

  /// 제목만 있고 내용이 없으면, 제목을 내용으로 표시한다.
  if (content == null) {
    content = title;
    title = null;
  }

  showPlatformDialog(
    context: fb.context,
    builder: (_) => PlatformAlertDialog(
      title: title != null ? Text(title) : null,
      content: Text(content),
      actions: <Widget>[
        PlatformDialogAction(
          child: PlatformText(t('Ok')),
          onPressed: () => Navigator.pop(fb.context),
        ),
      ],
    ),
  );
}

openPopupPage(childWidget) {
  return showGeneralDialog(
    context: fb.context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(fb.context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return childWidget;
    },
  );
}

/// 게시글 또는 코멘트 작성 박스 오픈
///
openForumBox(childWidget) {
  // if (postOrComment != null) {
  //   if (postOrComment.deletedAt != null) {
  //     alert(t(ALREADY_DELETED));
  //     return null;
  //   }
  //   if (postOrComment.uid != fb.user.uid) {
  //     alert(t(NOT_MINE));
  //     return null;
  //   }
  // }
  return openPopupPage(childWidget);
}

/// Can it be synchronous by using async/await? So, it does not need to use callback functions.
confirm({String title, String content, Function onNo, Function onYes}) {
  return showPlatformDialog<void>(
    context: fb.context,
    builder: (context) {
      return AlertDialog(
        title: title != null ? Text(title) : null,
        content: Text(content),
        actions: <Widget>[
          FlatButton(
            child: T('no'),
            onPressed: () {
              if (onNo != null) onNo();
              _back();
            },
          ),
          FlatButton(
            child: T('yes'),
            onPressed: () {
              onYes();
              _back();
            },
          )
        ],
      );
    },
  );
}

/// 랜덤 문자열을 리턴한다.
///
/// [length] 리턴 받을 랜덤 문자열의 길이를 정 할 수 있다.
String randomString({int length = 24}) {
  var rand = new Random();
  var codeUnits = new List.generate(length, (index) {
    return rand.nextInt(33) + 89;
  });

  return new String.fromCharCodes(codeUnits);
}

/// Generates a positive random integer uniformly distributed on the range
/// from [min], inclusive, to [max], exclusive.
int randomInt(int min, int max) {
  final _random = new Random();
  return min + _random.nextInt(max - min);
}

/// Enum 의 값을 바탕으로 enum 요소 참조
/// 예)
/// ``` dart
/// enum animals { cat, dog }
/// var re = enumValueFromString('dog', animals.value);
/// ```
/// 위와 같은 경우, re 는 `animals.dog` 값이 된다.
/// 일반적으로 `enum`의 경우, 값으로 해당 요소를 참조 할 수 없지만, 아래의 함수로 가능하다.
String enumValueToString(Object o) => o.toString().split('.').last;
T enumValueFromString<T>(String key, Iterable<T> values) => values.firstWhere(
      (v) => v != null && key == enumValueToString(v),
      orElse: () => null,
    );

/// 다른 라우트로 이동을 한다.
open(String route, {arguments}) {
  return Navigator.pushNamed(
    fb.context,
    route,
    arguments: arguments,
  );
}

///
void back({arguments}) {
  Navigator.pop(fb.context, arguments);
}

/// Returns true if [obj] is one of null, false, empty string, or 0.
bool isEmpty(obj) {
  return obj == null || obj == '' || obj == false || obj == 0;
}
