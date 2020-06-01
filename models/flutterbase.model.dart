import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.category.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.comment.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.defines.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.post.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.user.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.texts.dart';
import 'package:fluttercms/flutterbase/models/flutterbase.post.model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FlutterbaseModel extends ChangeNotifier {
  FlutterbaseModel() {
    /// 사용자가 로그인/로그아웃을 할 때 `user` 를 업데이트하고 notifyListeners() 를 호출.
    (() {
      auth.onAuthStateChanged.listen((FirebaseUser u) async {
        _user = u;
        notifyListeners();
        if (u == null) {
          // print('EngineModel::onAuthStateChanged() user logged out');
          auth.signInAnonymously();
        } else {
          // print('EngineModel::onAuthStateChanged() user logged in: $u');
          // print('Anonymous: ${u.isAnonymous}, ${u.email}');

          if (loggedIn) {
            try {
              // print('@TODO: get user data');
              // engineUser = await userProfile();
              // print('engineUser: ');
              // print(engineUser);
              userDocument = await profile();
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
  /// - `user` 값은 `onAuthStateChanged` 에서만 변경되어야 한다. 그래서 실수하지 않도록 getter 로 값을 읽을 수 있도록 한다.
  /// - `user` 값을 `onAuthStateChagned` 에서 관리하는 이유는
  ///   - 사용자가 로그아웃으로 자동으로 `Anonymous`로 로그인을 한다.
  ///     즉, 로그아웃을 하면  `user` 값은 `Anonymous` 사용자로 자동으로 변경이 되는 데, 이를 감지하고 업데이트 하기 위해서이다.
  FirebaseUser _user;
  FirebaseUser get user => _user;

  /// 사용자 도큐먼트 값을 가진다.
  FlutterbaseUser userDocument;

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
    return userDocument.isAdmin;
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

  /// 로그인을 한다.
  ///
  /// `Firebase Auth` 에 직접 로그인을 한다.
  /// 에러가 있으면 에러를 throw 하고,
  /// 로그인이 성공하면 `notifiyListeners()`를 한 다음, `FirebaseUser` 객체를 리턴한다.
  ///
  /// 주의 할 것은
  /// - `user` 변수는 이 함수에서 직접 업데이트 하지 않고 `onAuthStateChanged()`에서 자동 감지를 해서 업데이트 한다.
  ///
  ///
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
      // print("signed in " + user.displayName);

      /// 파이어베이스에서 이미 로그인을 했으므로, GoogleSignIn 에서는 바로 로그아웃을 한다.
      /// GoogleSignIn 에서 로그아웃을 안하면, 다음에 로그인을 할 때, 다른 계정으로 로그인을 못한다.
      await _googleSignIn.signOut();
      return user;
    } catch (e) {
      // print('loginWithGoogleAccount::');
      // print(e);
      throw e.message;
    }
  }

  /// 사용자 정보 Collection 에서 Document 가져와 파싱해서 리턴한다.
  ///
  /// - 사용자 Document 는 존재하지 않을 수 있다. null 일 수 있다. (테스트 하는 경우)
  ///
  Future<FlutterbaseUser> profile() async {
    // print('profile: user.uid: ${user.uid}');

    final doc = await _userDoc(user.uid).get();
    return FlutterbaseUser.fromMap(doc.data);
  }

  CollectionReference get _userCol => store.collection('users');
  DocumentReference _userDoc(String uid) {
    return _userCol.document(uid);
  }

  CollectionReference get _postCol => store.collection('posts');
  DocumentReference _postDoc(String id) {
    return _postCol.document(id);
  }

  CollectionReference _commentCol(String postId) {
    return _postDoc(postId).collection('comments');
  }

  DocumentReference _commentDoc(String postId, String commentId) {
    return _commentCol(postId).document(commentId);
  }

  CollectionReference get _categoryCol => store.collection('categories');
  DocumentReference _categoryDoc(String id) {
    return _categoryCol.document(id);
  }

  /// 게시글 작성
  ///
  /// - id 는 도큐먼트 ID 에 저장하지 않는다.
  /// - category 는 카테고리이다.
  /// - uid 는 자동 저장된다.
  /// - [createdAt], [updatedAt] 도 자동 저장된다.
  Future<FlutterbasePost> postEdit(Map<String, dynamic> data) async {
    if (data == null) throw INPUT_IS_EMPTY;
    if (data['category'] == null) throw CATEGORY_IS_EMPTY;
    String id = data['id'];
    data.remove('id');

    data['uid'] = user.uid;
    data['updatedAt'] = FieldValue.serverTimestamp();

    if (id == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
      final ref = await _postCol.add(data);
      id = ref.documentID;
    } else {
      await _postDoc(id).updateData(data);
    }
    return await postGet(id);
  }

  Future<FlutterbasePost> postGet(id) async {
    return FlutterbasePost.fromMap((await _postDoc(id).get()).data, id: id);
  }

  /// 게시글 삭제
  ///
  /// - 실제로 도큐먼트를 삭제하지 않고, 제목, 내용, 사진 등을 없애거나 삭제됨으로 표시한다.
  ///     - 즉, 삭제됨으로 업데이트를 하는 것이다.
  /// - `deletedAt` 에 값을 기록한다.
  ///
  /// 입력 변수 [post] 에 (call by reference) 삭제돔 정보를 업데이트한다. 즉, 부모 함수에서 따로 수정 할 필요가 없다.
  Future<FlutterbasePost> postDelete(FlutterbasePost post) async {
    post.title = POST_TITLE_DELETED;
    post.content = POST_CONTENT_DELETED;
    post.urls = [];

    /// 주의 시간은 임시로 참 값만 등록한다.
    post.deletedAt = 1;

    return await postEdit({
      'title': POST_TITLE_DELETED,
      'content': POST_CONTENT_DELETED,
      'urls': [],
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 카테고리 목록 전체를 가져온다.
  Future<List<FlutterbaseCategory>> loadCategories() async {
    final QuerySnapshot snapshot = await _categoryCol.getDocuments();
    final docs = snapshot.documents;
    if (docs.length == 0) return [];

    List<FlutterbaseCategory> cats = [];
    for (final doc in docs) {
      cats.add(FlutterbaseCategory.fromMap(doc.data));
    }

    return cats;
  }

  Future<FlutterbaseCategory> categoryEdit({
    @required String id,
    String title,
    String description,
  }) async {
    if (isEmpty(id)) throw ID_IS_EMPTY;
    final doc = _categoryDoc(id);
    await doc.setData({'id': id, 'title': title, 'description': description},
        merge: true);
    final data = (await doc.get()).data;
    return FlutterbaseCategory.fromMap(data);
  }

  /// 카테고리를 삭제한다.
  ///
  Future categoryDelete(String id) async {
    await _categoryDoc(id).delete();
  }

  Future vote(data) async {
    // return await callFunction({'route': 'post.like', 'data': data});
  }

  /// 코멘트 생성
  ///
  /// 도큐먼트에  저장되어야하는 값
  /// - uid (생성 할 때에만)
  /// - content
  /// - order
  /// - createdAt (생성 할 때에만 )
  /// - updatedAt
  /// - deletedAt (삭제 할 때에만 )
  ///
  /// * postCreate(), postUpdate() 와는 달리 자동으로 FlutterbaseComment 로 변환하지 않는다.
  ///   이유는 백엔드로 부터 데이터를 가져 왔을 때, 곧바로 랜더링 준비를 하면(Model 호출 등) 클라이언트에 무리를 줄 수 있다.
  ///   미리 하지 말고 필요(랜더링)할 때, 그 때 준비해서 해당 작업을 하면 된다.
  /// * 코멘트를 백엔드로 가져 올 때, 랜더링 준비를 하지 않으므로, 여기서도 하지 않는다.
  /// [postId] 는 글 id
  /// [commentId] 는 코멘트 Id. 생성에는 필없다.
  /// [parentCommentDepth] 는 코멘트 깊이 단계. 수정에는 필요 없다.
  /// 1 부터 12 의 값이 저장되어야 한다.
  /// 1단계 코멘트인 경우, [parentCommentDepth] 를 0 으로 입력하면 된다. 그러면 코드에서 +1을 해서 저장한다.
  /// 2단계 코멘트의 경우, [parentCommentDepth] 를 1 로 이력하면, +1 을 해서 2로 저장한다.
  ///
  /// [lastSiblingCommentOrder] 는 형제의 마지막 코멘트의 order. 수정에는 필요 없다.
  /// [data.content] 글 내용
  /// [data.urls] 는 사진 url 목록
  Future<FlutterbaseComment> commentEdit({
    @required String postId,
    String commentId,
    int parentCommentDepth,
    String lastSiblingCommentOrder,
    Map<String, dynamic> data,
  }) async {
    /// 코멘트 저장 값 준비
    data['updatedAt'] = FieldValue.serverTimestamp();
    data['displayName'] = user.displayName;

    if (commentId == null) {
      /// 코멘트 생성

      /// 생성할 때에만 uid 저장
      data['uid'] = user.uid;

      /// depth 와 order 값을 찾는다. +1 을 하기 전의 값을 전달한다.
      String order =
          getCommentOrder(parentCommentDepth, lastSiblingCommentOrder);

      data['createdAt'] = FieldValue.serverTimestamp();
      data['depth'] = parentCommentDepth + 1;
      data['order'] = order;

      final ref = await _commentCol(postId).add(data);
      commentId = ref.documentID;
    } else {
      /// 코멘트 수정
      ///
      /// 수정 할 때에는 간단하게 코멘트 내용만 수정 하면 된다.
      // print('data: $data');
      await _commentDoc(postId, commentId).updateData(data);
    }
    return await commentGet(postId, commentId);
  }

  /// 코멘트 삭제
  ///
  /// - 삭제되었음의 데이터를 업데이트한다.
  /// - 삭제된 도큐먼트를 리턴한다.
  /// - notifyListeners() 를 하지 않는다.
  ///
  Future commentDelete({String postId, FlutterbaseComment comment}) async {
    return await commentEdit(
      postId: postId,
      commentId: comment.commentId,
      data: {
        'content': COMMENT_CONTENT_DELETED,
        'urls': [],
        'deletedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  Future<FlutterbaseComment> commentGet(String postId, String commentId) async {
    final snapshot = await _commentDoc(postId, commentId).get();
    if (!snapshot.exists) throw FIALED_TO_GET_COMMENT;
    return FlutterbaseComment.fromMap(snapshot.data,
        postId: postId, commentId: commentId);
  }

  Future<List<FlutterbaseComment>> commentsGet(String postId) async {
    final snapshot = await _commentCol(postId)
        .orderBy('order', descending: true)
        .getDocuments();
    final docs = snapshot.documents;
    List<FlutterbaseComment> _comments = [];
    docs.forEach(
      (doc) {
        final docData = doc.data;
        var _re = FlutterbaseComment.fromMap(docData,
            postId: postId, commentId: doc.documentID);

        // print('comment content: ${_re.content}');
        _comments.add(_re);
      },
    );
    return _comments;
  }

  /// [depth] 를 바탕으로 새로운 list order 값을 만들어 리턴
  ///
  /// [depth] 는 +1을 하기 전의 값이어야 한다.
  /// 배열은 0 부터 시작으로, [dpeth] 가 0 이면 1단계, 1이면 2단계로 된다.
  getCommentOrder(int depth, String order) {
    if (order == null) {
      order =
          '99999.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999';
    } else {
      List<String> parts = order.split('.');
      String el = parts[depth];
      int computed = int.parse(el) - 1;
      parts[depth] = computed.toString();
      order = parts.join('.');
    }
    return order;
  }

  /// 형제 코멘트을 리턴한다.
  ///
  /// 주의: 부모를 포함해서 현제 코멘트들을 리스트로 리턴한다.
  /// - 부모가 '99999' 의 값을 가지기 때문이다.
  ///
  List<FlutterbaseComment> findSiblings({
    @required FlutterbaseComment parentComment,
    @required List<FlutterbaseComment> comments,
  }) {
    int depth = parentComment.depth;

    String beginOrder = parentComment.order.substring(0, depth * 6);
    String endOrder = parentComment.order.substring((depth + 1) * 6);

    List<FlutterbaseComment> sibliings = [];
    for (int i = 0; i < comments.length; i++) {
      final c = comments[i];

      String cBeginOrder = c.order.substring(0, depth * 6);
      String cEndOrder = c.order.substring((depth + 1) * 6);
      if (beginOrder == cBeginOrder && endOrder == cEndOrder) {
        sibliings.add(c);
      }
    }
    return sibliings;
  }

  /// 형제 중 마지막 코멘트를 리턴한다.
  ///
  /// [parentComment] - 부모 코멘트
  ///   부모 코멘트의 `depth` 를 보고, 같은 `depth` 중 order 가 가장 낮은 것을 리턴한다.
  ///   글 내용에서 `reply` 버튼을 클릭한 경우는 null 일 수 있다.
  /// [comments] - 현재 글의 코멘트 목록. 코멘트 목록에서 형제 중 마지막 코멘트를 찾는 것이다.
  ///
  /// 코멘트가 없으면 null 이 러턴된다.
  /// 부모 코멘트에 자식 코멘트가 하나도 없으면, 즉, 형제 코멘트가 없으면, 부모 코멘트가 리턴된다.
  FlutterbaseComment findLastSiblingComment({
    @required FlutterbaseComment parentComment,
    @required List<FlutterbaseComment> comments,
  }) {
    /// 코멘트가 작성되지 않은 경우, (글에 코멘트가 하나도 없는 경우,)
    if (comments.length == 0) return null;

    if (parentComment == null) {
      return comments.last;
    }

    final List<FlutterbaseComment> siblings =
        findSiblings(parentComment: parentComment, comments: comments);

    return siblings.last;
  }
}
