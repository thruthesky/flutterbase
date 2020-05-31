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
    Timer(Duration(milliseconds: 200), () {
      run();
    });
  }

  int successCount = 0;
  int errorCount = 0;

  run() async {
    // await testRegister();
    await testComment();

    showResult();
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
      previousCommentOrder: null,
      content: 'A',
    );
    eq(commentA.content, 'A');

    List<FlutterbaseComment> _comments = await fb.commentsGet(post.id);
    eq(_comments.length, 1);
    eq(_comments[0].depth, 1);
    eq(_comments[0].order,
        '99999.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create Comment B
    FlutterbaseComment commentB = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: 0, // 1단계
      previousCommentOrder: commentA.order,
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
      previousCommentOrder: commentB.order,
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
      previousCommentOrder: commentC.order, // 이전 단계 order. C 다음이므로 이전 C.
      content: 'CA',
    );

    eq(commentCA.depth, 2);
    eq(commentCA.order,
        '99997.99998.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create Comment D
    FlutterbaseComment commentD = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: 0, // 1단계
      previousCommentOrder: commentC.order,
      content: 'D',
    );

    eq(commentD.depth, 1);
    eq(commentD.order,
        '99996.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create Comment C -> CA -> CAA

    FlutterbaseComment commentCAA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentCA.depth, // 이전 단계 depth. CA 다음 이전은 CA.
      previousCommentOrder: commentCA.order, // 이전 단계 order. CA 다음이므로 이전은 CA.
      content: 'CAA',
    );

    eq(commentCAA.depth, 3);
    eq(commentCAA.order,
        '99997.99998.99998.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create B -> BA
    ///
    FlutterbaseComment commentBA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentB.depth,
      previousCommentOrder: commentB.order,
      content: 'BA',
    );

    eq(commentBA.depth, 2);
    eq(commentBA.order,
        '99998.99998.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create A -> AA
    FlutterbaseComment commentAA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentA.depth,
      previousCommentOrder: commentA.order,
      content: 'AA',
    );
    eq(commentAA.depth, 2);
    eq(commentAA.order,
        '99999.99998.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create A -> AB
    FlutterbaseComment commentAB = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentA.depth,
      previousCommentOrder: commentAA.order,
      content: 'AB',
    );

    eq(commentAB.order,
        '99999.99997.99999.99999.99999.99999.99999.99999.99999.99999.99999.99999');

    /// Create A -> AC
    FlutterbaseComment commentAC = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentA.depth,
      previousCommentOrder: commentAB.order,
      content: 'AC',
    );



    /// Create B -> BA -> BAA
    ///
    FlutterbaseComment commentBAA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentBA.depth,
      previousCommentOrder: commentBA.order,
      content: 'BAA',
    );



    /// Create B -> BA -> BAAA
    ///
    FlutterbaseComment commentBAAA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentBAA.depth,
      previousCommentOrder: commentBAA.order,
      content: 'BAAA',
    );



    /// Create B -> BA -> BAAB
    ///
    FlutterbaseComment commentBAAB = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentBAA.depth,
      previousCommentOrder: commentBAAA.order, // 이전 댓글. 부모 댓글의 것이 아님.
      content: 'BAAB',
    );



    /// Create B -> BA -> BAAC
    ///
    FlutterbaseComment commentBAAC = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentBAA.depth,
      previousCommentOrder: commentBAAB.order, // 이전 댓글. 부모 댓글의 것이 아님.
      content: 'BAAC',
    );



    /// Create B -> BA -> BAA -> BAAB -> BAABA
    ///
    FlutterbaseComment commentBAABA = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentBAAB.depth,
      previousCommentOrder: commentBAAB.order, // 이전 댓글. 부모 댓글의 것이 아님.
      content: 'BAABA',
    );




    /// Create B -> BB
    ///
    FlutterbaseComment commentBB = await fb.commentEdit(
      postId: post.id,
      parentCommentDepth: commentB.depth,
      previousCommentOrder: commentBAAC.order, // 이전 댓글. 부모 댓글의 것이 아님.
      content: 'BB',
    );




    print('------> crate done !!');
    _comments = await fb.commentsGet(post.id);
    _comments.forEach((element) {
      print('created:');
      print(element);
    });

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
      'BB',
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
