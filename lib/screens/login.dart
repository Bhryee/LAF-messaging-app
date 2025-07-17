import 'package:flutter/material.dart';
import 'package:laf_app/services/auth/auth_service.dart';
import '../widgets/button.dart';
import '../widgets/textfield.dart';

class LoginScreen extends StatelessWidget {
  // email and password controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final void Function()? onTap;



  LoginScreen({super.key, required this.onTap});

  Future<void> goToLogin(BuildContext context) async { // ← async ekle
    final AuthService _auth = AuthService();

    try {
      await _auth.signInWithEmailAndPassword(_emailController.text, _passwordController.text); // ← await ekle
      print("Giriş başarılı!"); // ← Bu log görünecek
    } catch (e) {
      print("Giriş hatası: $e"); // ← Bu log görünecek
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Hata'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Logo
            Image.asset("media/logo.png"),

            SizedBox(height: 60,),

            //Welcome text
            Text("Hesabınıza giriş yapın",
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.black38,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),

            SizedBox(height: 40,),

            MyTextField(
              hintText: "Email", obsecureText: false,
              controller: _emailController,
            ),

            SizedBox(height: 20,),

            MyTextField(
              hintText: "Şifre", obsecureText: true,
              controller: _passwordController,
            ),

            SizedBox(height: 40,),

            //Start button
            MyButton(text: "GİRİŞ YAP",
                onTap: () => goToLogin(context)),

            SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Hesabın yok mu? ", style: TextStyle(color: Colors.black38),),
                GestureDetector(
                  onTap: onTap,
                    child: Text("Üye ol", style: TextStyle(color : Colors.black54, fontWeight: FontWeight.bold),))
              ],
            )
          ],
        ),
      ),
    );;
  }
}
