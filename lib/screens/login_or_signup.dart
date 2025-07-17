import 'package:flutter/material.dart';
import 'package:laf_app/screens/signup.dart';

import 'login.dart';

class LoginOrSignup extends StatefulWidget {
  const LoginOrSignup({super.key});

  @override
  State<LoginOrSignup> createState() => _LoginOrSignupState();
}

class _LoginOrSignupState extends State<LoginOrSignup> {
  bool showLoginScreen = true;

  void toggleScreens(){
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginScreen){
      return LoginScreen(
        onTap: toggleScreens,
      );
    }else{
      return SignupScreen(
        onTap: toggleScreens,
      );
    };
  }
}
