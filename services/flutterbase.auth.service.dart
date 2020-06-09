import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.defines.dart';
import '../../settings.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FlutterbaseAuthService {
  /// 페이스북 계정 로그인
  ///
  /// 아래의 코드는 페이스 북 계정 로그인 코드

  Future<FirebaseUser> loginWithFacebookAccount({@required BuildContext context}) async {
    String result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CustomWebViewForFacebookLogin(
                selectedUrl:
                    'https://www.facebook.com/dialog/oauth?client_id=${Settings.facebookAppId}&redirect_uri=${Settings.facebookLoginRedirectUrl}&response_type=token&scope=email,public_profile,',
              ),
          maintainState: true),
    );

    if (result == null) throw FAILED_ON_FACEBOOK_LOGIN;
    try {
      final facebookAuthCred =
          FacebookAuthProvider.getCredential(accessToken: result);
      final AuthResult authResult =
          await _auth.signInWithCredential(facebookAuthCred);
      return authResult.user;
    } catch (e) {
      throw e;
    }
  }

  /// 구글 계정 로그인
  ///
  /// 아래의 코드는 구글 계정 로그인 코드

  /// 파이어베이스 로그인을 연결하는 플러그인.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// 구글 계정으로 로그인을 한다.
  ///
  /// 사용자가 취소를 누르면 null 이 리턴된다.
  Future<FirebaseUser> loginWithGoogleAccount() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      print("signed in " + user.displayName);

      /// 파이어베이스에서 이미 로그인을 했으므로, GoogleSignIn 에서는 바로 로그아웃을 한다.
      /// GoogleSignIn 에서 로그아웃을 안하면, 다음에 로그인을 할 때, 다른 계정으로 로그인을 못한다.
      await _googleSignIn.signOut();
      return user;
    } on PlatformException catch (e) {
      final code = e.code.toLowerCase();
      throw code;
    } catch (e) {
      print('loginWithGoogleAccount::');
      print(e);
      throw e.message;
    }
  }
}

/// 페이스북 로그인을 위한 커스텀 웹 뷰
///
/// - 사용자가 로그인 버튼을 클릭하면, 이 웹 뷰가 열리고,
/// - 이메일/비밀번호를 입력하고,
/// - 로그인이 성공하면, token 을 받아서, 부모 위젯으로 리턴한다.
class CustomWebViewForFacebookLogin extends StatefulWidget {
  final String selectedUrl;

  CustomWebViewForFacebookLogin({this.selectedUrl});

  @override
  _CustomWebViewForFacebookLoginState createState() =>
      _CustomWebViewForFacebookLoginState();
}

class _CustomWebViewForFacebookLoginState
    extends State<CustomWebViewForFacebookLogin> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (url.contains("#access_token")) {
        succeed(url);
      }

      if (url.contains(
          "https://www.facebook.com/connect/login_success.html?error=access_denied&error_code=200&error_description=Permissions+error&error_reason=user_denied")) {
        denied();
      }
    });
  }

  denied() {
    Navigator.pop(context);
  }

  succeed(String url) {
    var params = url.split("access_token=");

    var endparam = params[1].split("&");

    Navigator.pop(context, endparam[0]);
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
        url: widget.selectedUrl,
        appBar: new AppBar(
          backgroundColor: Color.fromRGBO(66, 103, 178, 1),
          title: new Text("Facebook login"),
        ));
  }
}
