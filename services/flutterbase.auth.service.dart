import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FlutterbaseAuthService {


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