import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.category_list.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.comment.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.defines.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.post.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.user.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.texts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FlutterbaseModel extends ChangeNotifier {
  FlutterbaseModel() {
    /// 사용자가 로그인/로그아웃을 할 때 `user` 를 업데이트하고 notifyListeners() 를 호출.
    (() {
      auth.onAuthStateChanged.listen((FirebaseUser u) async {
        _user = u;
        notifyListeners();
        if (u == null) {
          print('EngineModel::onAuthStateChanged() user logged out');
          auth.signInAnonymously();
        } else {
          print('EngineModel::onAuthStateChanged() user logged in: $u');
          print('Anonymous: ${u.isAnonymous}, ${u.email}');

          if (loggedIn) {
            try {
              // print('@TODO: get user data');
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

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// 파이어베이스 Firebase
  final Firestore store = Firestore.instance;

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Returns the context of [navigatorKey]
  BuildContext get context => navigatorKey.currentState.overlay.context;

  /// 로그인한 사용자 FirebaseUser
  ///
  /// - `auth.currentUser()` 가 Future 이다. 그래서 이것을 사용하기가 쉽지 않다.
  /// - 따라서 `onAuthStateChanged` 에서 사용자가 로그인/로그아웃을 할 때 마다 `user` 정보를 업데이트해서 보관한다.
  ///
  /// - 로그인을 안한 상태이면 null.
  /// - `user` 값은 `onAuthStateChanged` 에서만 변경되어야 한다. 그래서 getter 로 값을 읽을 수 있도록 한다.
  FirebaseUser _user;
  FirebaseUser get user => _user;

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

  /// 회원 가입을 한다.
  ///
  /// `users` collection 에 비밀번호는 저장하지 않는다.
  Future<void> register(Map<String, dynamic> data) async {
    if (data == null) throw INVALID_PARAMETER;
    if (isEmpty(data['email'])) throw EMAIL_IS_EMPTY;
    if (isEmpty(data['password'])) throw PASSWORD_IS_EMPTY;
    if (isEmpty(data['displayName'])) throw DISPLAYNAME_IS_EMPTY;

    AuthResult re = await auth.createUserWithEmailAndPassword(
      email: data['email'],
      password: data['password'],
    );

    if (re == null || re.user == null) throw FAILED_TO_REGISTER;
    data.remove('password');

    data['uid'] = re.user.uid;
    await _userDoc(user.uid).setData(data);
  }

  Future<void> profileUpdate(Map<String, dynamic> data) async {
    if (notLoggedIn) throw LOGIN_FIRST;
    if (data['email'] != null) throw EMAIL_CANNOT_BY_CHANGED;
    // print('profileUpdate email: ${data['email']}');

    if (data['displayName'] != null || data['photoUrl'] != null) {
      final up = UserUpdateInfo();
      up.displayName = data['displayName'];
      up.photoUrl = data['photoUrl'];
      await user.updateProfile(up);
    }
    await _userDoc(user.uid).setData(data, merge: true);
    await user.reload();
  }

  /// 사용자 로그인을 한다.
  ///
  /// `Firebase Auth` 를 바탕으로 로그인을 한다.
  /// 에러가 있으면 에러를 throw 하고,
  /// 로그인이 성공하면 `notifiyListeners()`를 한 다음, `FirebaseUser` 객체를 리턴한다.
  /// 주의 할 것은 `user` 변수는 이 함수에서 직접 업데이트 하지 않고 `onAuthStateChanged()`에서 자동 감지를 해서 업데이트 한다.
  Future<FirebaseUser> login(String email, String password) async {
    if (email == null || email == '') throw INPUT_EMAIL;
    if (password == null || password == '') throw INPUT_PASSWORD;
    AuthResult result = await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    notifyListeners();
    return result.user;
  }

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
          (await auth.signInWithCredential(credential)).user;
      print("signed in " + user.displayName);

      /// 파이어베이스에서 이미 로그인을 했으므로, GoogleSignIn 에서는 바로 로그아웃을 한다.
      /// GoogleSignIn 에서 로그아웃을 안하면, 다음에 로그인을 할 때, 다른 계정으로 로그인을 못한다.
      await _googleSignIn.signOut();
      return user;
    } catch (e) {
      print('loginWithGoogleAccount::');
      print(e);
      throw e.message;
    }
  }

  /// 사용자 정보를 Firestore Document 에서 가져와서 리턴한다.
  Future<FlutterbaseUser> profile() async {
    // print('profile: user.uid: ${user.uid}');

    final doc = await _userDoc(user.uid).get();
    return FlutterbaseUser.fromDocument(doc.data);
  }

  CollectionReference get _userCol => store.collection('users');
  DocumentReference _userDoc(String uid) {
    return _userCol.document(uid);
  }

  CollectionReference get _postCol => store.collection('posts');
  DocumentReference _postDoc(String id) {
    return _postCol.document(id);
  }

  /// 게시글 삭제
  ///
  /// 입력값은 프로토콜 문서 참고
  Future<FlutterbasePost> postDelete(String id) async {
    // final post = await callFunction({'route': 'post.delete', 'data': id});
    // return FlutterbasePost.fromEngineData(post);
    return null;
  }

  /// 카테고리 목록 전체를 가져온다.
  Future<FlutterbaseCategoryList> categoryList() async {
    // return EngineCategoryList.fromEngineData(
    //     await callFunction({'route': 'category.list'}));
    return null;
  }

  Future vote(data) async {
    // return await callFunction({'route': 'post.like', 'data': data});
  }

  /// 코멘트 생성
  ///
  /// * 입력값은 프로토콜 문서 참고
  /// * postCreate(), postUpdate() 와는 달리 자동으로 FlutterbaseComment 로 변환하지 않는다.
  ///   이유는 백엔드로 부터 데이터를 가져 왔을 때, 곧바로 랜더링 준비를 하면(Model 호출 등) 클라이언트에 무리를 줄 수 있다.
  ///   미리 하지 말고 필요(랜더링)할 때, 그 때 준비해서 해당 작업을 하면 된다.
  /// * 코멘트를 백엔드로 가져 올 때, 랜더링 준비를 하지 않으므로, 여기서도 하지 않는다.
  Future<FlutterbaseComment> commentCreate(data) async {
    // final comment =
    //     await callFunction({'route': 'comment.create', 'data': data});
    // // return comment;
    // return FlutterbaseComment.fromEngineData(comment);
    return null;
  }

  /// 코멘트 수정
  ///
  /// * 입력값은 프로토콜 문서 참고
  /// * commentCreate() 의 설명을 참고.
  Future<FlutterbaseComment> commentUpdate(data) async {
    // final comment =
    //     await callFunction({'route': 'comment.update', 'data': data});
    // // return comment;
    // return FlutterbaseComment.fromEngineData(comment);
    return null;
  }

  /// 코멘트 삭제
  ///
  /// * 입력값은 프로토콜 문서 참고
  Future commentDelete(String id) async {
    // final deleted = await callFunction({'route': 'comment.delete', 'data': id});
    // return deleted;
  }
}
