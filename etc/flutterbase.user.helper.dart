import 'package:fluttercms/flutterbase/etc/flutterbase.defines.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';

/// 사용자 정보
///
/// Collection 에 Document 가 없는 경우, 모두 null 값을 가진다.
/// 주의: Firebase 에서 어떤 경우에는 `photoURL` 과 같이 쓰고 어떤 경우에는 `photoUrl` 로 쓴다.
/// Flutterbase 에서는 `photoUrl` 로 통일해서 쓴다.
///   - `Firebase Auth` 에서 읽을 때과 쓸 때, `photoURL` 로 해야하는 것에 주의한다.
/// 
/// - `photoURL` 로 쓰는 경우,
///   - `Firebase Auth` 와
///   - `Admin SDK` 에서 Auth 값을 일고 쓸 때에 `photoURL` 로 쓴다.
///     참고: https://firebase.google.com/docs/auth/web/manage-users
///     참고: `Functions` https://firebase.google.com/docs/auth/admin/manage-users
/// - `photoUrl` 로 쓴ㄴ 경우,
///   - `Flutter(Dart) Firebase Auth 패키지` 에서 `UserUpdateInfo()` 에서 `photUrl` 로 쓴다.
/// 
class FlutterbaseUser {
  String email;
  String displayName;
  String phoneNumber;
  String photoUrl;
  int birthday;
  bool isAdmin;


  /// 프로필 사진 업로드를 위한 임시 변수
  /// 서버에 저장되지 않는다.
  List<dynamic> urls = [];
  FlutterbaseUser({
    this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    this.birthday,
    this.isAdmin,
  });
  factory FlutterbaseUser.fromMap(Map<dynamic, dynamic> data) {
    // print('user profile data: $data');
    if (data == null) {
      // print('User profile is null. User need to update his profile!');
      alert(t(UPDATE_PROFILE));
      return FlutterbaseUser();
    }
    bool isAdmin = false;

    if (data['isAdmin'] != null && data['isAdmin'] == true) isAdmin = true;

    /// TODO: 왜 birthday 가 문자열로 저장이 되는지 원인을 모르겠다. 저장 할 때, 문자열로 저장이 되나?
    int birthday;
    if (data['birthday'] is String) {
      birthday = int.parse(data['birthday']);
    } else {
      birthday = data['birthday'];
    }

    return FlutterbaseUser(
      email: data['email'],
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      photoUrl: data['photoUrl'],
      birthday: birthday,
      isAdmin: isAdmin,
    );
  }

  @override
  String toString() {
    return "email: $email\ndisplayName:$displayName\nphoneNumber:$phoneNumber\nphotoUrl:$photoUrl\nbirthday:$birthday";
  }
}
