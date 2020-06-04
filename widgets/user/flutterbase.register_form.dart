import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../../etc/flutterbase.defines.dart';
import '../../etc/flutterbase.globals.dart';
import '../../etc/flutterbase.user.helper.dart';
import '../../widgets/flutterbase.space.dart';
import '../../widgets/flutterbase.text.dart';
import '../../widgets/flutterbase.text_button.dart';
import '../../widgets/upload/flutterbase.upload_icon.dart';
import '../../widgets/user/flutterbase.register_user_photo.dart';
import '../../widgets/user/flutterbase.upload_progress_bar.dart';
import 'package:validators/validators.dart';

class FlutterbaseRegisterFrom extends StatefulWidget {
  FlutterbaseRegisterFrom({
    @required this.onError,
    @required this.onRegisterSuccess,
    @required this.onUpdateSuccess,
  });

  final Function onError;
  final Function onRegisterSuccess;
  final Function onUpdateSuccess;
  @override
  _FlutterbaseRegisterFromState createState() =>
      _FlutterbaseRegisterFromState();
}

class _FlutterbaseRegisterFromState extends State<FlutterbaseRegisterFrom> {
  FlutterbaseUser user = FlutterbaseUser();

  int progress = 0;
  bool inSubmit = false;
  bool inLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  /// Gets user registration data from the form
  getFormData() {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String nickname = _nicknameController.text;
    final String phoneNumber = _phoneNumberController.text;
    final String birthday = _birthdayController.text;

    /// 여기서 부터. 회원 정보에서 displayName, phoneNumber, photoUrl 이... Auth 에 저장되고, Firestore 에 저장되지 않는지 확인.
    /// 회원 정보 수정. Auth 에 있는 값과 Firestore 에 있는 값을 모두 잘 수정하는지 확인.
    ///
    final data = {
      'displayName': nickname,
      'phoneNumber': phoneNumber,
      'birthday': birthday,
    };

    /// 회원 가입
    if (fb.notLoggedIn) {
      /// 회원 가입시에만 이메일과 비빌번호를 지정
      data['email'] = email;
      data['password'] = password;

      /// 회원 가입을 할 때에는 사진이 `Anonymous` 로 업로드 되어져있는데,
      ///   - 그 사진이 `userDocument.photoUrl` 과 `user.urls` 에도 저장되어져 있다.
      if (user.urls != null && user.urls.length > 0) {
        data['photoUrl'] = user.urls[0];
      }
    }
    return data;
  }

  @override
  void initState() {
    if (fb.loggedIn) {
      loadProfile();
    }

    super.initState();
  }

  loadProfile() async {
    setState(() => inLoading = true);
    try {
      user = await fb.profile();
      // print(user);
      if (mounted) {
        setState(() {
          _nicknameController.text = user.displayName;
          _phoneNumberController.text = user.phoneNumber;
          _birthdayController.text = user.birthday.toString();
        });
      }
    } catch (e) {
      // print(e);
      widget.onError(e);
      // AppService.alert(null, t(e));
    }

    setState(() => inLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FlutterbaseUploadIcon(
          user,
          onProgress: (p) {
            /// 업로드 Percentage 표시
            setState(() {
              progress = p;
            });
          },
          onUploadComplete: (String url) async {
            print('uploaded url: $url');

            /// 사진 업로드
            try {
              /// 회원 가입을 이미 한 경우, 회원 정보 페이지 이면,
              /// 사진을 업로드하면, 바로 수정. 즉, 전송 버튼을 누르지 않아도 이미 업데이트가 되어져 버린다.
              if (fb.loggedIn) {
                await fb.profileUpdate({'photoUrl': url});
                print('userDocument.photoUrl: ${fb.userDocument.photoUrl}');
                setState(() {/** FlutterbaseModel Provider 받지 않아서 state 갱신 */});
              }
              {
                fb.userDocument.photoUrl = url;
                fb.notify();
              }
            } catch (e) {
              widget.onError(e);
            }
          },
          onError: (e) => widget.onError(e),
          icon: FlutterbaseRegisterUserPhoto(
            user,
            onError: (e) => widget.onError(e),
          ),
        ),
        Visibility(
          visible: progress > 0,
          child: Column(
            children: <Widget>[
              FlutterbaseBigSpace(),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 100,
                  ),
                  Expanded(child: FlutterbaseUploadProgressBar(progress)),
                  SizedBox(
                    width: 100,
                  ),
                ],
              ),
            ],
          ),
        ),
        FlutterbaseBigSpace(),
        if (inLoading) PlatformCircularProgressIndicator(),
        fb.notLoggedIn
            ? TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onSubmitted: (text) {},
                decoration: InputDecoration(
                  hintText: t('input email'),
                ),
              )
            : Text(fb.user.email),
        FlutterbaseSpace(),
        if (fb.notLoggedIn)
          TextField(
            controller: _passwordController,
            onSubmitted: (text) {},
            decoration: InputDecoration(
              hintText: t('input password'),
            ),
          ),
        FlutterbaseSpace(),
        TextField(
          controller: _nicknameController,
          onSubmitted: (text) {},
          decoration: InputDecoration(
            hintText: t('input nickname'),
          ),
        ),
        FlutterbaseSpace(),
        TextField(
          controller: _phoneNumberController,
          onSubmitted: (text) {},
          decoration: InputDecoration(
            hintText: t('input phone number'),
          ),
        ),
        FlutterbaseSpace(),
        Row(
          children: <Widget>[
            Flexible(
              flex: 2,
              child: TextField(
                controller: _birthdayController,
                onSubmitted: (text) {},
                decoration: InputDecoration(
                  hintText: t('input birthday'),
                ),
              ),
            ),
            Flexible(
              child: FlatButton(
                onPressed: () {
                  DatePicker.showDatePicker(
                    context,
                    showTitleActions: true,
                    minTime: DateTime(1940, 1, 1),
                    maxTime: DateTime(2020, 1, 1),
                    onChanged: (date) {
                      // print('change $date');
                    },
                    onConfirm: (date) {
                      // print('confirm $date');
                      String ymd = date
                          .toString()
                          .split(' ')
                          .elementAt(0)
                          .split('-')
                          .join('');
                      // print('ymd: $ymd');
                      setState(() {
                        _birthdayController.text = ymd;
                      });
                    },
                    currentTime: DateTime.parse(
                        (isEmpty(_birthdayController.text) ||
                                !isNumeric(_birthdayController.text))
                            ? '20000101'
                            : _birthdayController.text),
                    locale: enumValueFromString(
                        appLanguageCode(), LocaleType.values),
                  );
                },
                child: T(
                  SHOW_DATE_PICKER,
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
        FlutterbaseBigSpace(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlutterbaseTextButton(
              showSpinner: inSubmit,
              text: fb.notLoggedIn ? t(REGISTER_BUTTON) : t(UPDATE_PROFILE_BUTTON),
              onTap: () async {
                /// 전송 버튼
                if (inSubmit) return;
                if (_birthdayController.text.length != 8) {
                  alert(t(BIRTHDAY_8_DIGITS));
                  return;
                }
                setState(() => inSubmit = true);
                final data = getFormData();
                try {
                  if (fb.notLoggedIn) {
                    await fb.register(data);
                    widget.onRegisterSuccess();
                  } else {
                    await fb.profileUpdate(data);
                    widget.onUpdateSuccess();
                  }
                } catch (e) {
                  widget.onError(e);
                }
                setState(() => inSubmit = false);
              },
              // child: fb.notLoggedIn ? T('register submit') : T('update submit'),
            ),
          ],
        ),
      ],
    );
  }
}
