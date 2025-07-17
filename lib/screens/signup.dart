import 'package:flutter/material.dart';
import '../services/auth/auth_service.dart';
import '../widgets/button.dart';
import '../widgets/textfield.dart';

class SignupScreen extends StatefulWidget {
  final void Function()? onTap;

  const SignupScreen({super.key, required this.onTap});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Avatar
  String _selectedAvatar = 'avatar1'; // Varsayılan seçim
  bool _isLoading = false;
  final AuthService _authService = AuthService();


  void _onAvatarSelected(String avatarId) {
    setState(() {
      _selectedAvatar = avatarId;
    });
    print("Seçilen avatar: $avatarId");
  }

  Future<void> goToSignup(BuildContext context) async {

    if (_usernameController.text.trim().isEmpty) {
      _showErrorDialog(context, 'Kullanıcı adı boş olamaz!');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog(context, 'Email boş olamaz!');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showErrorDialog(context, 'Şifre en az 6 karakter olmalıdır!');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog(context, 'Şifreler eşleşmiyor!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      await _authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        username: _usernameController.text.trim(),
        selectedAvatar: _selectedAvatar,
      );



      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hesap başarıyla oluşturuldu!'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      print("Kayıt hatası: $e");
      if (mounted) {
        _showErrorDialog(context, _getErrorMessage(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('email-already-in-use')) {
      return 'Bu email adresi zaten kullanımda!';
    } else if (error.contains('weak-password')) {
      return 'Şifre çok zayıf!';
    } else if (error.contains('invalid-email')) {
      return 'Geçersiz email adresi!';
    } else {
      return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarOptions = _authService.getAvatarOptions();

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset("media/logo.png"),
              const SizedBox(height: 10),

              // Welcome text
              const Text(
                "Hesap oluşturun",
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Avatar seçimi bölümü
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Profil Fotoğrafın Seç',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Avatar seçenekleri
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: avatarOptions.entries.map((entry) {
                        final avatarId = entry.key;
                        final avatarAssetPath = entry.value;
                        final isSelected = _selectedAvatar == avatarId;

                        return GestureDetector(
                          onTap: () => _onAvatarSelected(avatarId),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Color(0xFF644839) : Colors.grey.shade400,
                                width: isSelected ? 4 : 2,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ] : null,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                avatarAssetPath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 20),


              MyTextField(
                hintText: "Kullanıcı Adı",
                obsecureText: false,
                controller: _usernameController,
              ),
              const SizedBox(height: 10),

              MyTextField(
                hintText: "Email",
                obsecureText: false,
                controller: _emailController,
              ),
              const SizedBox(height: 10),

              MyTextField(
                hintText: "Şifre",
                obsecureText: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 10),

              MyTextField(
                hintText: "Şifre Tekrar",
                obsecureText: true,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 30),

              // Submit button
              MyButton(
                text: "ÜYE OL",
                onTap: _isLoading ? null : () => goToSignup(context),
              ),
              const SizedBox(height: 10),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Zaten hesabın var mı? ",
                    style: TextStyle(color: Colors.black38),
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      "Giriş Yap",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}