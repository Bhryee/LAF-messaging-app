import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laf_app/screens/home.dart';
import 'package:laf_app/screens/login_or_signup.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user login
          if (snapshot.hasData){
            return HomeScreen();
          } else{
            return LoginOrSignup();
          }

          // user not login
        },
      ),
    );
  }
}
