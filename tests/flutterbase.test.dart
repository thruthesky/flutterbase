import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.comment.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.defines.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.post.helper.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.user.helper.dart';

class FlutterbaseTest {
  FlutterbaseTest() {
    print('--> FlutterbaseTest()');

    /// 로그인 될 때까지 기다림
    Timer(Duration(milliseconds: 400), () {
      run();
    });
  }

  int successCount = 0;
  int errorCount = 0;

  run() async {
    // await testRegister();
    // await testComment();

    await testFindSiblings();
    showResult();
  }

  testFindSiblings() async {
    List<FlutterbaseComment> _comments =
        await fb.commentsGet('2soXtBpIp9aTRN3CGMr6');
    final siblings =
        fb.findSiblings(parentComment: _comments[4], comments: _comments);
    print('sibilings: 2soXtBpIp9aTRN3CGMr6');
    print(siblings);
  }

  showResult() {
    Timer(Duration(seconds: 2), () {
      print('''
        ----TEST RESULT ----\n\n
        No. of Tests: ${successCount + errorCount}
        Success: $successCount, Error: $errorCount
        \n
        ''');
    });
  }

  eq(a, b) {
    if (a == b) {
      successCount++;
      print('____[ OK/$successCount ]: $a is equal to $b');
    } else {
      errorCount++;
      print('____[ FAIL/$errorCount ]: $a is NOT equal to $b');
    }
  }

  fail(v) {
    errorCount++;
    print('____[ FAIL/$errorCount ]: $v');
  }

  testRegister() async {
    try {
      await fb.register(null);
    } catch (e) {
      eq(e, INVALID_PARAMETER);
    }
    try {
      await fb.register({});
    } catch (e) {
      eq(e, EMAIL_IS_EMPTY);
    }
    try {
      await fb.register({'email': ''});
    } catch (e) {
      eq(e, EMAIL_IS_EMPTY);
    }

    try {
      await fb.register({'email': 0});
    } catch (e) {
      eq(e, EMAIL_IS_EMPTY);
    }

    try {
      await fb.register({'email': null});
    } catch (e) {
      eq(e, EMAIL_IS_EMPTY);
    }

    try {
      await fb.register({'email': 'a'});
    } catch (e) {
      eq(e, PASSWORD_IS_EMPTY);
    }
    try {
      await fb.register({'email': 'a', 'password': 'p'});
    } catch (e) {
      eq(e, DISPLAYNAME_IS_EMPTY);
    }

    try {
      await fb.register({'email': 'a', 'password': 'p', 'displayName': 'd'});
    } on PlatformException catch (e) {
      eq(e.runtimeType, PlatformException);
      eq(e.code, ERROR_INVALID_EMAIL);
    } catch (e) {
      fail('must be invalid error');
    }

    try {
      int n = randomInt(100000, 999999);
      await fb.register(
          {'email': 'user$n@test.com', 'password': 'p', 'displayName': 'd'});
    } catch (e) {
      eq(e.runtimeType, PlatformException);
      eq(e.code, ERROR_WEAK_PASSWORD);
    }

    int n = randomInt(100000, 999999);
    final registerData = {
      'email': 'user$n@test.com',
      'password': 'p,!$n,',
      'displayName': 'd',
      'birthday': 19731016
    };
    try {
      await fb.register(registerData);
    } catch (e) {
      fail('must succeed on register');
    }

    try {
      FlutterbaseUser u = await fb.profile();
      eq(u.email, registerData['email']);
      eq(u.birthday, registerData['birthday']);
    } catch (e) {
      fail('error on profile: $e');
    }

    try {
      await fb.profileUpdate({'email': 'emailcannot@bechanged.com'});
    } catch (e) {
      eq(e, EMAIL_CANNOT_BY_CHANGED);
    }
    try {
      await fb.profileUpdate({'displayName': 'new name'});
      FlutterbaseUser u = await fb.profile();
      eq(u.displayName, 'new name');
    } catch (e) {
      fail('must success');
    }

    /// 회원 도큐먼트는 삭제 할 수 없다.
    /// 퍼미션 에러 발생.
    try {
      await fb.store.collection('users').document(fb.user.uid).delete();
    } catch (e) {
      /// permission denied.
      eq(e.code, 'Error 7');
    }
  }

  createTestPost() async {
    try {
      /// 카테고리가 존재 해야 함
      return await fb.postEdit({
        'title': 'title',
        'category': 'qna',
      });
    } catch (e) {
      fail('Must create on creating a post $e');
    }
  }

  testComment() async {
    /// Create a post
    FlutterbasePost post = await createTestPost();

    // print(post);

    /// Create Comment A
    FlutterbaseComment commentA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: 0, // 1단계
      lastSiblingCommentOrder: null,
      content: 'A',
    );
    eq(commentA.content, 'A');

    List<FlutterbaseComment> _comments = await fb.commentsGet(post.id);
    eq(_comments.length, 1);
    eq(_comments[0].depth, 1);
    eq(_comments[0].order,
        '99999.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create Comment B
    FlutterbaseComment B = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: 0, // 1단계
      lastSiblingCommentOrder: commentA.order,
      content: 'B',
    );

    _comments = await fb.commentsGet(post.id);
    eq(_comments.length, 2);
    eq(_comments[1].depth, 1);
    eq(_comments[1].order,
        '99998.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create Comment C
    FlutterbaseComment commentC = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: 0, // 1단계
      lastSiblingCommentOrder: B.order,
      content: 'C',
    );

    _comments = await fb.commentsGet(post.id);
    eq(_comments.length, 3);
    eq(_comments[2].depth, 1);
    eq(_comments[2].order,
        '99997.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create Comment C -> CA

    FlutterbaseComment commentCA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentC.depth, // 이전 단계 depth. C 다음 이전 C.
      lastSiblingCommentOrder: commentC.order, // 이전 단계 order. C 다음이므로 이전 C.
      content: 'CA',
    );

    eq(commentCA.depth, 2);
    eq(commentCA.order,
        '99997.99998.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create Comment D
    FlutterbaseComment commentD = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: 0, // 1단계
      lastSiblingCommentOrder: commentC.order,
      content: 'D',
    );

    eq(commentD.depth, 1);
    eq(commentD.order,
        '99996.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create Comment C -> CA -> CAA

    FlutterbaseComment commentCAA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentCA.depth, // 이전 단계 depth. CA 다음 이전은 CA.
      lastSiblingCommentOrder: commentCA.order, // 이전 단계 order. CA 다음이므로 이전은 CA.
      content: 'CAA',
    );

    eq(commentCAA.depth, 3);
    eq(commentCAA.order,
        '99997.99998.99998.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create B -> BA
    ///
    FlutterbaseComment BA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: B.depth,
      lastSiblingCommentOrder: B.order,
      content: 'BA',
    );

    eq(BA.depth, 2);
    eq(BA.order,
        '99998.99998.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create A -> AA
    FlutterbaseComment commentAA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentA.depth,
      lastSiblingCommentOrder: commentA.order,
      content: 'AA',
    );
    eq(commentAA.depth, 2);
    eq(commentAA.order,
        '99999.99998.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create A -> AB
    FlutterbaseComment commentAB = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentA.depth,
      lastSiblingCommentOrder: commentAA.order,
      content: 'AB',
    );

    eq(commentAB.order,
        '99999.99997.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create A -> AC
    FlutterbaseComment commentAC = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentA.depth,
      lastSiblingCommentOrder: commentAB.order,
      content: 'AC',
    );

    /// Create B -> BA -> BAA
    ///
    FlutterbaseComment BAA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: BA.depth,
      lastSiblingCommentOrder: BA.order,
      content: 'BAA',
    );

    /// Create B -> BA -> BAAA
    ///
    FlutterbaseComment commentBAAA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: BAA.depth,
      lastSiblingCommentOrder: BAA.order,
      content: 'BAAA',
    );

    /// Create B -> BA -> BAAB
    ///
    FlutterbaseComment commentBAAB = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: BAA.depth,
      lastSiblingCommentOrder: commentBAAA.order, // 이전 댓글. 부모 댓글의 것이 아님.
      content: 'BAAB',
    );

    /// Create B -> BA -> BAAC
    ///
    FlutterbaseComment commentBAAC = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: BAA.depth,
      lastSiblingCommentOrder: commentBAAB.order, // 이전 댓글. 부모 댓글의 것이 아님.
      content: 'BAAC',
    );

    /// Create B -> BA -> BAA -> BAAB -> BAABA
    ///
    FlutterbaseComment commentBAABA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentBAAB.depth,
      lastSiblingCommentOrder: commentBAAB.order, // 이전 댓글. 부모 댓글의 것이 아님.
      content: 'BAABA',
    );

    /// Create B -> BB
    ///
    FlutterbaseComment BB = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: B.depth,
      lastSiblingCommentOrder: commentBAAC.order, // 이전 댓글. 부모 댓글의 것이 아님.
      content: 'BB',
    );

    /// 형제 중 마지막 코멘트의 order

    /// BBA
    ///
    FlutterbaseComment BBA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: BB.depth, // 부모
      lastSiblingCommentOrder: BB.order, // 형제가 없으면, 부모
      content: 'BBA',
    );

    FlutterbaseComment BC = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: B.depth, // 부모
      lastSiblingCommentOrder: BB.order, // 형재 중 마지막
      content: 'BC',
    );

    FlutterbaseComment BCA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: BC.depth, // 부모
      lastSiblingCommentOrder: BC.order, // 형제가 없으면, 부모
      content: 'BCA',
    );

    FlutterbaseComment BD = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: B.depth, // 부모
      lastSiblingCommentOrder: BC.order, // 형제 중 마지막
      content: 'BD',
    );

    FlutterbaseComment BAB = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: BA.depth, // 부모
      lastSiblingCommentOrder: BAA.order, // 형제 중 마지막
      content: 'BAB',
    );

    _comments = await fb.commentsGet(post.id);
    _comments.forEach((element) {
      // print('created:');
      // print(element);
    });

    // print('------> crate done. length: ${_comments.length}');

    List<String> expected = [
      'A',
      'AA',
      'AB',
      'AC',
      'B',
      'BA',
      'BAA',
      'BAAA',
      'BAAB',
      'BAABA',
      'BAAC',
      'BAB',
      'BB',
      'BBA',
      'BC',
      'BCA',
      'BD',
      'C',
      'CA',
      'CAA',
      'D',
    ];
    bool done = true;
    for (int i = 0; i < _comments.length; i++) {
      if (_comments[i].content != expected[i]) {
        print(
            '----------> failed: i: $i, ${_comments[i].content} : ${expected[i]}');
        done = false;
        break;
      }
    }
    eq(done, true);
  }
}
