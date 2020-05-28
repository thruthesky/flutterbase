import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttercms/flutterbase/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/flutterbase.texts.dart';

class FlutterbaseModel extends ChangeNotifier {
  FlutterbaseModel() {
    /// 사용자가 로그인/로그아웃을 할 때 `user` 를 업데이트하고 notifyListeners() 를 호출.
    (() {
      auth.onAuthStateChanged.listen((_user) async {
        user = _user;
        notifyListeners();
        if (user == null) {
          print('EngineModel::onAuthStateChanged() user logged out');
          auth.signInAnonymously();
        } else {
          print('EngineModel::onAuthStateChanged() user logged in: $user');
          print('Anonymous: ${user.isAnonymous}, ${user.email}');

          if (loggedIn) {
            try {
              print('@TODO: get user data');
              // engineUser = await userProfile();
              // print('engineUser: ');
              // print(engineUser);

            } catch (e) {
              // print('got profile error: ');
              // print(e);
              // onError(e);
              alert(e);
            }
          }
        }
      });
    })();

    final _engineI18N = FlutterbaseI18N();
    _engineI18N.i18nKeyCheck();
  }

  /// 파이어베이스 로그인을 연결하는 플러그인.
  final FirebaseAuth auth = FirebaseAuth.instance;

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Returns the context of [navigatorKey]
  BuildContext get context => navigatorKey.currentState.overlay.context;

  /// 사용자가 로그인을 하면, 사용자 정보를 가진다. 로그인을 안한 상태이면 null.
  FirebaseUser user;

  /// 사용자가 로그인을 했으면 참을 리턴
  ///
  /// 단, Anonymous 로그인은 로그인을 하지 않은 것으로 간주한다.
  bool get loggedIn {
    return user != null && user.isAnonymous == false;
  }

  /// 사용자가 로그인을 안했으면 참을 리턴.
  bool get notLoggedIn {
    return loggedIn == false;
  }

  /// 관리자 이면 참을 리턴한다.
  bool get isAdmin {
    return false;
  }

  /// 사용자 로그아웃을 하고 `notifyListeners()` 를 한다. `user` 는 Listeners 에서 자동 업데이트된다.
  logout() async {
    await auth.signOut();
    notifyListeners();
  }
}
