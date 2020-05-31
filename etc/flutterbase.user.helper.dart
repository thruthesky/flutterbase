/// 사용자 정보
///
/// Collection 에 Document 가 없는 경우, 모두 null 값을 가진다.

class FlutterbaseUser {
  String email;
  String displayName;
  String phoneNumber;
  String photoURL;
  int birthday;
  bool isAdmin;
  FlutterbaseUser({
    this.email,
    this.displayName,
    this.phoneNumber,
    this.photoURL,
    this.birthday,
    this.isAdmin,
  });
  factory FlutterbaseUser.fromMap(Map<dynamic, dynamic> data) {
    bool isAdmin = false;
    if (data['isAdmin'] != null && data['isAdmin'] == true) isAdmin = true;


    /// TODO: 왜 birthday 가 문자열로 저장이 되는지 원인을 모르겠다. 저장 할 때, 문자열로 저장이 되나?
    int birthday;
    if ( data['birthday'] is String ) {
      birthday = int.parse(data['birthday']);
    } else {
      birthday = data['birthday'];
    }

    if (data == null)
      return FlutterbaseUser();
    else
      return FlutterbaseUser(
        email: data['email'],
        displayName: data['displayName'],
        phoneNumber: data['phoneNumber'],
        photoURL: data['photoURL'],
        birthday: birthday,
        isAdmin: isAdmin,
      );
  }

  @override
  String toString() {
    return "email: $email\ndisplayName:$displayName\nphoneNumber:$phoneNumber\nphotoURL:$photoURL\nbirthday:$birthday";
  }
}
