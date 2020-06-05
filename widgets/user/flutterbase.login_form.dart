import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/flutterbase.space.dart';
import '../../etc/flutterbase.defines.dart';
import '../../etc/flutterbase.globals.dart';
import '../../widgets/flutterbase.circle.dart';
import '../../widgets/flutterbase.text.dart';
import '../../widgets/flutterbase.text_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FlutterbaseLoginForm extends StatefulWidget {
  FlutterbaseLoginForm({
    @required this.onLogin,
    @required this.onError,
  });

  final Function onLogin;
  final Function onError;

  @override
  _FlutterbaseLoginFormState createState() => _FlutterbaseLoginFormState();
}

class _FlutterbaseLoginFormState extends State<FlutterbaseLoginForm> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool inSubmit = false;

  /// Gets user registration data from the form
  /// TODO - form validation
  getFormData() {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final data = {
      'email': email,
      'password': password,
    };
    return data;
  }

  Future<FirebaseUser> _handleSignIn() async {
    try {
      return await fb.loginWithGoogleAccount();
    } catch (e) {
      print('Got error: ');
      print(e);
      widget.onError(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FlutterbaseBigSpace(),
          FlutterbaseBigSpace(),
          FlutterbaseBigSpace(),
          FlutterbaseCircle(
            padding: EdgeInsets.all(24.0),
            color: Theme.of(context).accentColor,
            child: Icon(
              Icons.verified_user,
              size: 112,
              color: Theme.of(context).buttonColor,
            ),
          ),
          FlutterbaseBigSpace(),
          FlutterbaseBigSpace(),
          FlutterbaseBigSpace(),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (text) {},
            decoration: InputDecoration(
              hintText: t('input email'),
            ),
          ),
          FlutterbaseSpace(),
          TextField(
            controller: _passwordController,
            onSubmitted: (text) {},
            decoration: InputDecoration(
              hintText: t('input password'),
            ),
          ),
          FlutterbaseBigSpace(),
          FittedBox(
            child: FlutterbaseTextButton(
              showSpinner: inSubmit,
              text: t(LOGIN_BUTTON),
              onTap: () async {
                if (inSubmit) return;
                setState(() => inSubmit = true);
                final data = getFormData();
                try {
                  final user = await fb.login(data['email'], data['password']);
                  widget.onLogin(user);
                } catch (e) {
                  widget.onError(e);
                }
                setState(() => inSubmit = false);
              },
            ),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlutterbaseTextButton(
                text: t(LOST_PASSWORD_BUTTON),
              ),
              FlutterbaseTextButton(
                text: t(REGISTER_TITLE),
              ),
            ],
          ),
          FlutterbaseBigSpace(),
          FlutterbaseBigSpace(),
          T(OR_LOGIN_WITH),
          FlutterbaseBigSpace(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                child: FaIcon(
                  FontAwesomeIcons.googlePlus,
                  size: 46,
                  color: Colors.red,
                ),
                onTap: () async {
                  return alert('not supported yet');
                  try {
                    final user = await _handleSignIn();
                    print(user);
                  } catch (e) {
                    widget.onError(e);
                  }
                },
              ),
              FlutterbasePageSpace(),
              GestureDetector(
                child: FaIcon(
                  FontAwesomeIcons.facebook,
                  size: 46,
                  color: Colors.indigo,
                ),
                onTap: () {
                  return alert('not supported yet');
                },
              ),
              FlutterbasePageSpace(),
              GestureDetector(
                child: FlutterbaseCircle(
                  elevation: 0,
                  color: Theme.of(context).accentColor,
                  child: FaIcon(FontAwesomeIcons.twitter,
                      size: 30, color: Theme.of(context).buttonColor),
                ),
                onTap: () {
                  return alert('no supported yet');
                },
              ),
            ],
          ),
          // RaisedButton(
          //   onPressed: () async {
          //     try {
          //       final user = await _handleSignIn();
          //       print(user);
          //     } catch (e) {
          //       widget.onError(e);
          //     }
          //   },
          //   child: T('Google Sign In'),
          // ),
        ],
      ),
    );
  }
}
