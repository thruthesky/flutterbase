import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttercms/flutterbase/etc/flutterbase.globals.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.button.dart';
import 'package:fluttercms/flutterbase/widgets/flutterbase.space.dart';

class FlutterbaseLoginForm extends StatefulWidget {
  FlutterbaseLoginForm({
    this.hintEmail = 'Email',
    this.hintPassword = 'Password',
    this.textSubmit = 'Submit',
    this.hintGoogleSignIn = 'Google Sign In',
    @required this.onLogin,
    @required this.onError,
  });

  final String hintEmail;
  final String hintPassword;
  final String textSubmit;
  final String hintGoogleSignIn;
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (text) {},
          decoration: InputDecoration(
            hintText: widget.hintEmail,
          ),
        ),
        FlutterbaseSpace(),
        TextField(
          controller: _passwordController,
          onSubmitted: (text) {},
          decoration: InputDecoration(
            hintText: widget.hintPassword,
          ),
        ),
        FlutterbaseSpace(),
        FlutterbaseButton(
          loader: inSubmit,
          text: widget.textSubmit,
          onPressed: () async {
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
        RaisedButton(
          onPressed: () async {
            try {
              final user = await _handleSignIn();
              print(user);
            } catch (e) {
              widget.onError(e);
            }
          },
          child: Text(widget.hintGoogleSignIn),
        ),
      ],
    );
  }
}
