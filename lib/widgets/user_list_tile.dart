import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/auth/auth_service.dart';

class UserListTile extends StatelessWidget {
  final String text;
  final String? selectedAvatar; // Avatar ID'si eklendi
  final void Function()? onTap;

  const UserListTile({
    super.key,
    required this.text,
    required this.onTap,
    this.selectedAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    // Avatar ID'sini asset path'e çevir
    final avatarAssetPath = _authService.getAvatarAssetPath(selectedAvatar);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10)
        ),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Profil fotoğrafı - Asset'ten yüklenen
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[400],
              child: ClipOval(
                child: Image.asset(
                  avatarAssetPath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Hata durumunda varsayılan ikon
                    return const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 25,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 15),

            // Kullanıcı bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Mesaja dokunarak sohbete başlayın...",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Mesaj bilgisi (opsiyonel)
            const SizedBox(height: 5),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}