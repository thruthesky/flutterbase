class FlutterbaseUser {
  String email;
  String displayName;
  String phoneNumber;
  String photoURL;
  String birthday;
  FlutterbaseUser({
    this.email,
    this.displayName,
    this.phoneNumber,
    this.photoURL,
    this.birthday,
  }) {}
  factory FlutterbaseUser.fromDocument(Map<dynamic, dynamic> data) {
    return FlutterbaseUser(
      email: data['email'],
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      photoURL: data['photoURL'],
      birthday: data['birthday'],
    );
  }

  @override
  String toString() {
    return "email: $email\ndisplayName:$displayName\nphoneNumber:$phoneNumber\nphotoURL:$photoURL\nbirthday:$birthday";
  }
}
