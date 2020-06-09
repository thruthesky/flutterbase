import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


import 'package:firebase_auth/firebase_auth.dart';
import '../etc/flutterbase.category.helper.dart';
import '../etc/flutterbase.comment.helper.dart';
import '../etc/flutterbase.defines.dart';
import '../etc/flutterbase.globals.dart';
import '../etc/flutterbase.post.helper.dart';
import '../etc/flutterbase.user.helper.dart';
import '../etc/flutterbase.texts.dart';
import '../models/flutterbase.post.model.dart';

/// 앱의 전체 영역에서 사용되는 state 관리 모델
/// 
///
/// TODO: 이 모델에는 이런 저런 여러가지 함수가 포함되어져 있는데 이로 인해서 코드가 난잡 해 졌다.
///   - state 에 꼭 필요한 정보만 담고,
///   - 그 외에는 별도의 서비스 파일로 분리해야한다.
///   - 예를 들면, 가입/로그인/프로필 수정, 게시판 관련 쿼리, 카테고리 관련 쿼리는 state 관리에서 직접적인 코드가 아니다.
///     이런 코드를 별도의 라이브러리나 서비스로 빼 내야 한다.
///   그래야 깔끔하게 정리가 될 것 같다.
///
class FlutterbaseModel extends ChangeNotifier {
  FlutterbaseModel() {
    /// 사용자가 로그인/로그아웃을 할 때 `user` 를 업데이트하고 notifyListeners() 를 호출.
    (() {
      auth.onAuthStateChanged.listen((FirebaseUser u) async {
        _user = u;
        notify();
        if (u == null) {
          // print('EngineModel::onAuthStateChanged() user logged out');
          auth.signInAnonymously();
        } else {
          // print('EngineModel::onAuthStateChanged() user logged in: $u');
          // print('Anonymous: ${u.isAnonymous}, ${u.email}');

          /// 실제 사용자로 로그인을 한 경우, Anonymous 는 제외
          if (loggedIn) {
            try {
              userDocument = await profile();
              print('userDocument: $userDocument, email: ${user.email}');
              notify();
            } catch (e) {
              print('got profile error: ');
              print(e);
              alert(e);
            }
          } else {
            /// 로그 아웃을 한 경우 (Anonymous 로 로그인 한 경우 포함)
            userDocument = FlutterbaseUser();
            notify();
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
  FlutterbaseUser userDocument = FlutterbaseUser();

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
    return userDocument?.isAdmin == true;
  }

  notify() {
    notifyListeners();
  }

  /// 사용자 로그아웃을 하고 `notifyListeners()` 를 한다. `user` 는 Listeners 에서 자동 업데이트된다.
  logout() async {
    await auth.signOut();
    notify();
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


    data.remove('email');
    data.remove('password');
    data['uid'] = re.user.uid;

    await profileUpdate(data);

    // data['uid'] = re.user.uid;
    // await _userDoc(user.uid).setData(data);
  }

  /// 사용자 정보 업데이트
  ///
  /// `Firebase Auth` 에도 등록하고, `Firestore users` Collection 에도 등록한다.
  ///
  Future<void> profileUpdate(Map<String, dynamic> data) async {
    /// 로그인을 하지 않은 경우, 즉, 비 회원이 회원 가입 페이지에 있는 경우,
    if (notLoggedIn) {
      // /// 비 회원이 사진을 업로드하는 경우, Anonymous 계정에 업로드를 한다.
      // if (data['photoUrl'] != null || data['photoUrl'] == DELETED_PHOTO) {
      //   // final up = UserUpdateInfo();
      //   // up.photoUrl = data['photoUrl'];
      //   // await user.updateProfile(up);
      //   // await user.reload();
      //   // print('user.photoUrl: ${user.photoUrl}');
      //   userDocument.photoUrl = data['photoUrl'];
      //   notify();
      //   return;
      // } else {
      /// 비 회원이, 사진이 아닌 다른 정보를 업데이트 하면 에러
      throw LOGIN_FIRST;
      // }
    }

    /// 이메일 변경 불가
    if (data['email'] != null) throw EMAIL_CANNOT_BY_CHANGED;

    /// null 값이 저장되면 안된다.
    if (data.containsKey('email')) data.remove('email');

    /// 닉네임, 사진은 `Firebase Auth` 에 업데이트
    if (data['displayName'] != null || data['photoUrl'] != null) {
      final up = UserUpdateInfo();
      if (data['displayName'] != null) {
        up.displayName = data['displayName'];
      }
      if (data['photoUrl'] != null) {
        up.photoUrl = data['photoUrl'];
      }

      await user.updateProfile(up);

      /// Firebase Auth 정보 갱신
      await user.reload();
      _user = await auth.currentUser();

      data.remove('displayName');
      data.remove('photoUrl');
    }

    /// 사용자 도큐먼트 정보 업데이트
    await _userDoc(user.uid).setData(data, merge: true);

    /// 사용자 도큐먼트 정보 갱신
    userDocument = await profile();

    notify();
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
    notify();
    return result.user;
  }

  /// 구글 계정으로 로그인을 한다.
  ///
  /// 사용자가 취소를 누르면 null 이 리턴된다.
  // Future<FirebaseUser> loginWithGoogleAccount() async {
  //   try {
  //     final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) {
  //       return null;
  //     }
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     final AuthCredential credential = GoogleAuthProvider.getCredential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     final FirebaseUser user =
  //         (await auth.signInWithCredential(credential)).user;
  //     // print("signed in " + user.displayName);

  //     /// 파이어베이스에서 이미 로그인을 했으므로, GoogleSignIn 에서는 바로 로그아웃을 한다.
  //     /// GoogleSignIn 에서 로그아웃을 안하면, 다음에 로그인을 할 때, 다른 계정으로 로그인을 못한다.
  //     await _googleSignIn.signOut();
  //     return user;
  //   } catch (e) {
  //     // print('loginWithGoogleAccount::');
  //     // print(e);
  //     throw e.message;
  //   }
  // }

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

  CollectionReference get _likeCol => store.collection('likes');
  DocumentReference _likeDoc(String id) {
    return _likeCol.document(id);
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

    String id = data['id'];
    data.remove('id');

    data['uid'] = user.uid;
    data['displayName'] = user.displayName;

    /// TODO: 사진 첨부
    data['photoUrl'] = user.photoUrl;
    data['updatedAt'] = FieldValue.serverTimestamp();

    if (id == null) {
      /// 글 생성

      /// 글 생성하는 경우에는 카테고리 값이 들어와야 한다.
      if (data['category'] == null) throw CATEGORY_IS_EMPTY;

      /// 글 생성하는 경우, vote 초기화
      data['like'] = 0;
      data['dislike'] = 0;

      /// 글 작성 시간
      data['createdAt'] = FieldValue.serverTimestamp();
      final ref = await _postCol.add(data);
      id = ref.documentID;
    } else {
      /// 글 수정 또는 '삭제됨'으로 수정
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
  Future<FlutterbasePost> postDelete(FlutterbasePostModel postModel) async {
    print('post: $postModel.post');
    if (postModel.post.uid != user.uid) throw NOT_MINE;
    if (postModel.post.deletedAt != 0) throw ALREADY_DELETED;

    // postModel.post.title = POST_TITLE_DELETED;
    // postModel.post.content = POST_CONTENT_DELETED;
    // postModel.post.urls = [];

    postModel.post.inDeleting = true;
    postModel.notify();

    print('in deting: ${postModel.post.inDeleting}');

    try {
      FlutterbasePost _deleted = await postEdit({
        'id': postModel.post.id,
        'title': POST_TITLE_DELETED,
        'content': POST_CONTENT_DELETED,
        'urls': [],
        'deletedAt': FieldValue.serverTimestamp(),
      });

      postModel.post.replaceWith(_deleted);
      print('updated: ');
      postModel.notify();

      // 인터넷이 너무 빨라, 로더가 보이지 않는 것을 방지
      Timer(Duration(milliseconds: 400), () {
        postModel.post.inDeleting = false;
        postModel.notify();
      });

      return _deleted;
    } catch (e) {
      postModel.post.inDeleting = false;
      postModel.notify();
      throw e;
    }
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

  /// 추천/비추천을 한다.
  ///
  /// [post] 는 테스트를 할 때 사용한다. 테스트 할 때, [postModel] 값을 지정 할 수 없다.
  ///
  /// - 삭제된 글이면 vote 불가
  /// - 이미 vote 중이면 불가
  Future vote({
    FlutterbasePostModel postModel,
    FlutterbasePost post,
    FlutterbaseComment comment,
    String voteFor,
  }) async {
    var doc; // 추천을 하는 글 또는 코멘트
    DocumentReference docRef; // doc 의 Reference

    /// [postModel] 이 `null` 이면, [post] 의 것을 vote 한다.
    if (postModel != null) {
      doc = postModel.post;
      docRef = _postDoc(postModel.post.id);
    } else {
      doc = post;
      docRef = _postDoc(post.id);
    }

    /// [comment] 가 `null` 이 아니면, 코멘트를 vote 하는 것이다.
    if (comment != null) {
      docRef = _commentDoc(doc.id, comment.commentId);
      doc = comment; // 코멘트를 doc 에 저장
    }

    /// vote 중이면 리턴
    if (doc.inVoting) return;

    try {
      /// 추천 표시
      if (postModel != null) {
        doc.inVoting = true;
        postModel.notify();
      }

      String likeId = '${docRef.documentID}-${user.uid}';
      DocumentReference likeRef = _likeDoc(likeId);
      final increment = FieldValue.increment(1);
      final decrement = FieldValue.increment(-1);

      Map<String, dynamic> newLikeData = {};

      final WriteBatch batch = Firestore.instance.batch();

      /// 먼저 vote 를 했는지 확인. /likes/post_id_or_comment_id-uid/{ id: doc.id, uid: uid, vote: like or dislike }

      /// Race condition timing 을 줄이기 위해서 likes 도큐먼트를 먼저 읽고, 글/코멘트를 읽어야 한다.
      DocumentSnapshot snapshot = await likeRef.get();
      if (!snapshot.exists) {
        /// 처음 추천하는 경우
        /// 즉, 처음 vote 를 한다면, (문서가 존재하지 않는다면), vote 하고 1 증가.
        newLikeData = {
          'id': docRef.documentID,
          'uid': user.uid,
          'vote': voteFor
        };

        batch.setData(likeRef, newLikeData);
        batch.setData(docRef, {voteFor: increment}, merge: true);

        // await likeDoc.setData(newData);
      } else {
        var likeData = snapshot.data;

        /// 동일한 vote
        if (likeData['vote'] == voteFor) {
          batch.delete(likeRef);
          batch.setData(docRef, {voteFor: decrement}, merge: true);
        } else {
          /// 다른 vote
          newLikeData = {
            'id': docRef.documentID,
            'uid': user.uid,
            'vote': voteFor
          };
          batch.setData(likeRef, newLikeData);
          String otherVote = voteFor == 'like' ? 'dislike' : 'like';
          batch.setData(docRef, {voteFor: increment, otherVote: decrement},
              merge: true);
        }
      }

      await batch.commit();

      var re = (await docRef.get()).data;

      if (postModel != null) {
        doc.inVoting = false;
        doc.like = re['like'];
        doc.dislike = re['dislike'];
        postModel.notify();
      }

      return re;
    } catch (e) {
      /// doc.inVoting 을 false 로 하고, notifyListeners() 를 위해서 에러를 캡쳐 한 것이다.
      if (postModel != null) {
        doc.inVoting = false;
        postModel.notify();
      }
      throw e;
    }
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

    /// TODO: 사진 첨부
    data['photoUrl'] = user.photoUrl;

    print('comment edit data: $data');

    if (commentId == null) {
      /// 코멘트 생성

      /// 생성할 때에만 uid 저장
      data['uid'] = user.uid;

      /// 생성 할 때, vote 초기화
      data['like'] = 0;
      data['dislike'] = 0;

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
  Future commentDelete(
      {@required FlutterbasePostModel postModel,
      FlutterbaseComment comment}) async {
    comment.inDeleting = true;
    postModel.notify();

    print('comment.indeleeing: ${comment.inDeleting}');
    try {
      FlutterbaseComment _deleted = await commentEdit(
        postId: postModel.post.id,
        commentId: comment.commentId,
        data: {
          'content': COMMENT_CONTENT_DELETED,
          'urls': [],
          'deletedAt': FieldValue.serverTimestamp(),
        },
      );

      updateComment(postModel, _deleted);

      print('updated');

      // 인터넷이 너무 빨라, 로더가 빨리 끝나 보이지 않는 것을 방지
      Timer(Duration(milliseconds: 400), () {
        comment.inDeleting = false;
        postModel.notify();
        print('comment.indeleeing: ${comment.inDeleting}');
      });
    } catch (e) {
      comment.inDeleting = false;
      postModel.notify();
      throw e;
    }
  }

  /// 코멘트를 수정하고, 기존의 코멘트와 바꿔치기 한다.
  ///
  /// [comment] 업데이트된 코멘트
  /// - notifyListeners 를 한다.
  updateComment(FlutterbasePostModel postModel, FlutterbaseComment comment) {
    if (comment == null) return;

    int i = postModel.comments
        .indexWhere((element) => element.commentId == comment.commentId);
    postModel.comments.removeAt(i);
    postModel.comments.insert(i, comment);
    // print('commnet: $comment');
    postModel.notify();
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

  /// 내가 작성한 도큐먼트이면 true 를 리턴한다.
  bool myDoc(dynamic doc) {
    if (notLoggedIn) return false;
    if (doc.uid == null) return false;
    if (doc.uid != user.uid) return false;
    return true;
  }

  /// 삭제된 도큐먼트이면 true 를 리턴한다.
  bool deleted(dynamic doc) {
    if (doc.deletedAt == 0) return false;
    return true;
  }



}
