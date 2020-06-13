import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import '../../services/app.globals.dart';
import '../etc/flutterbase.defines.dart';
import '../etc/flutterbase.globals.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:kakao_flutter_sdk/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FlutterbaseAuthService {
  
  /// 카카오톡 로그인
  ///
  ///
  loginWithKakaotalkAccount() async {
    /// 카카오톡 로그인을 경우, 상황에 따라 메일 주소가 없을 수 있다. 메일 주소가 필수 항목이 아닌 경우,
    /// 따라서, id 로 메일 주소를 만들어서, 자동 회원 가입을 한다.
    ///
    try {
      /// 카카오톡 앱이 핸드폰에 설치되었는가?
      final installed = await isKakaoTalkInstalled();

      /// 카카오톡 앱이 설치 되었으면, 앱으로 로그인, 아니면 OAuth 로 로그인.
      final authCode = installed
          ? await AuthCodeClient.instance.requestWithTalk()
          : await AuthCodeClient.instance.request();

      AccessTokenResponse token =
          await AuthApi.instance.issueAccessToken(authCode);

      /// Store access token in AccessTokenStore for future API requests.
      /// 이걸 해야지, 아래에서 UserApi.instance.me() 와 같이 호출을 할 수 있나??
      AccessTokenStore.instance.toStore(token);

      String refreshedToken = token.refreshToken;
      print('refreshedToken: $refreshedToken');

      User user = await UserApi.instance.me();

      Map<String, String> data = {
        'email': 'kakaotalk${user.id}@kakao.com',
        'password': 'Settings.secretKey+${user.id}',
        'displayName': user.properties['nickname'],
        'photoUrl': user.properties['profile_image'],
      };

      loginOrRegisterThenUpdate(data);
    } on KakaoAuthException catch (e) {
      throw e;
    } on KakaoClientException catch (e) {
      throw e;
    } catch (e) {
      /// 카카오톡 로그인에서 에러가 발생하는 경우,
      /// 에러 메시지가 로그인 창에 표시가 되므로, 상단 위젯에서는 에러를 무시를 해도 된다.
      /// 예를 들어, 비밀번호 오류나, 로그인 취소 등.
      print('error: =====> ');
      print(e);
      throw e;
    }
  }

  /// 회원 로그인을 먼저 시도하고, 가입이 되어져 있지 않으면 가입을 한다.
  ///
  ///
  /// - 먼저, 로그인을 한다.
  /// - 만약, 로그인이 안되면, 회원 가입을 한다.
  /// - 회원 정보를 업데이트한다.
  Future<void> loginOrRegisterThenUpdate(Map<String, String> data) async {
    print('data: $data');

    try {
      await fb.login(data['email'], data['password']);
      print('loggedIn!');
      data.remove('email');
      data.remove('password');

      print('Going to update profile');
      await fb.profileUpdate(data);
    } on PlatformException catch (e) {
      if (e.code == ERROR_USER_NOT_FOUND) {
        /// Not regisgtered? then register
        print('Not registered. Going to register');
        await fb.register(data);
      } else {
        print('Error on login or profiel update:');
        print(e);
        throw e;
      }
    } catch (e) {
      print('what error error: $e');
      throw e;
    }
  }

  /// 페이스북 계정 로그인
  ///
  /// 아래의 코드는 페이스 북 계정 로그인 코드

  Future<FirebaseUser> loginWithFacebookAccount(
      {@required BuildContext context}) async {
        
    String result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CustomWebViewForFacebookLogin(
                selectedUrl:
                    'https://www.facebook.com/dialog/oauth?client_id=${app.settings.facebookAppId}&redirect_uri=${app.settings.facebookLoginRedirectUrl}&response_type=token&scope=email,public_profile,',
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
