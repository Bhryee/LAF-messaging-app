import 'package:flutter/material.dart';
import 'package:laf_app/screens/login_or_signup.dart';
import '../widgets/button.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});



  @override
  Widget build(BuildContext context) {
    //Tap button feature
    void goToLoginPage() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginOrSignup()),
      );
    }


    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Logo
            Image.asset("media/logo.png"),

            SizedBox(height: 80,),

            //Welcome text
            Text("BİR SOHBETİN \n40 YIL HATIRI VARDIR",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF644839),
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),

            SizedBox(height: 80,),

            //Start button
            MyButton(text : "LAFLAMAYA BAŞLA",
                onTap: goToLoginPage),
          ],
        ),
      ),
    );;
  }
}
