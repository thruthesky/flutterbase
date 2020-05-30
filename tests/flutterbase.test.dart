import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.defines.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.user.helper.dart';

class FlutterbaseTest {
  FlutterbaseTest() {
    print('--> FlutterbaseTest()');
    run();
  }

  int successCount = 0;
  int errorCount = 0;

  run() async {
    await testRegister();

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
}
