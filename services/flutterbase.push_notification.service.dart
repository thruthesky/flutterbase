import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import '../../settings.dart';
import '../../flutterbase/etc/flutterbase.globals.dart';

class FlutterbasePushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  Future init() async {
    if (Platform.isIOS) {
      _fcm.onIosSettingsRegistered.listen((event) {
        fb.setUserToken();
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    await _fcm.subscribeToTopic(Settings.fcmTopic);

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        _displayAndNavigate(message, true);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        _displayAndNavigate(message, false);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
        _displayAndNavigate(message, false);
      },
    );
  }

  /// Display notification & navigate
  ///
  /// Display & navigate
  ///
  /// 주의
  /// onMessage 콜백에서는 데이터가
  ///   {notification: {title: This is title., body: Notification test.}, data: {click_action: FLUTTER_NOTIFICATION_CLICK}}
  /// 와 같이 오는데,
  /// onResume & onLaunch 에서는 data 만 들어온다.
  void _displayAndNavigate(Map<String, dynamic> message, bool display) {
    var notification = message['notification'];

    /// iOS 에서는 title, body 가 `message['aps']['alert']` 에 들어온다.
    if (message['aps'] != null && message['aps']['alert'] != null) {
      notification = message['aps']['alert'];
    }
    // iOS 에서는 data 속성없이, 객체에 바로 저장된다.
    var data = message['data'] ?? message;

    // print('==> Got push data: $data');
    if (display) {
      // print('==> Display snackbar: notification: $notification');
      snackBar(
        title: notification['title'],
        message: notification['body'],
        durationInSeconds: 10,
        buttonText: t('ok'),
        data: data,
        onTap: (ret) {
          if (ret['postId'] != null) {
            open(Settings.postViewRoute, arguments: {'postId': ret['postId']});
          }
        },
        onClose: () => null,
      );
    } else {
      if (data['postId'] != null) {
        open(Settings.postViewRoute, arguments: {'postId': data['postId']});
      }
    }
  }
}
