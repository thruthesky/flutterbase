/// 사용자 정보
///
/// Collection 에 Document 가 없는 경우, 모두 null 값을 가진다.

class FlutterbaseUser {
  String email;
  String displayName;
  String phoneNumber;
  String photoURL;
  String birthday;
  bool isAdmin;
  FlutterbaseUser({
    this.email,
    this.displayName,
    this.phoneNumber,
    this.photoURL,
    this.birthday,
    this.isAdmin,
  }) {
    if (isAdmin == null) isAdmin = false;
  }
  factory FlutterbaseUser.fromMap(Map<dynamic, dynamic> data) {
    if (data == null)
      return FlutterbaseUser();
    else
      return FlutterbaseUser(
        email: data['email'],
        displayName: data['displayName'],
        phoneNumber: data['phoneNumber'],
        photoURL: data['photoURL'],
        birthday: data['birthday'],
        isAdmin: data['isAdmin'],
      );
  }

  @override
  String toString() {
    return "email: $email\ndisplayName:$displayName\nphoneNumber:$phoneNumber\nphotoURL:$photoURL\nbirthday:$birthday";
  }
}
