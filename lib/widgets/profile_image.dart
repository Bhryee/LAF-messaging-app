import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth/auth_service.dart';

class UserProfileWidget extends StatelessWidget {
  final bool showUsername;
  final double avatarRadius;

  const UserProfileWidget({
    Key? key,
    this.showUsername = true,
    this.avatarRadius = 25,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final User? currentUser = _authService.getCurrentUser();

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _authService.getUserProfile(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(strokeWidth: 2);
        }

        final userProfile = snapshot.data;
        final username = userProfile?['username'] ?? 'Kullanıcı';
        final selectedAvatar = userProfile?['selectedAvatar'] ?? 'avatar1';

        // Avatar ID'sini asset path'e çevir
        final avatarAssetPath = _authService.getAvatarAssetPath(selectedAvatar);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profil fotoğrafı - Asset'ten yüklenen
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.grey[300],
              child: ClipOval(
                child: Image.asset(
                  avatarAssetPath,
                  width: avatarRadius * 2,
                  height: avatarRadius * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Hata durumunda varsayılan ikon göster
                    return Icon(
                      Icons.person,
                      size: avatarRadius,
                      color: Colors.grey[600],
                    );
                  },
                ),
              ),
            ),

            // Kullanıcı adı (opsiyonel)
            if (showUsername) ...[
              const SizedBox(width: 10),
              Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// Drawer için profil header'ı
class DrawerProfileHeader extends StatelessWidget {
  const DrawerProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final User? currentUser = _authService.getCurrentUser();

    if (currentUser == null) {
      return const DrawerHeader(
        child: Text('Kullanıcı bulunamadı'),
      );
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _authService.getUserProfile(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final userProfile = snapshot.data;
        final username = userProfile?['username'] ?? 'Kullanıcı';
        final email = userProfile?['email'] ?? currentUser.email ?? '';
        final selectedAvatar = userProfile?['selectedAvatar'] ?? 'avatar1';

        // Avatar ID'sini asset path'e çevir
        final avatarAssetPath = _authService.getAvatarAssetPath(selectedAvatar);

        return DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profil fotoğrafı - Asset'ten yüklenen
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[300],
                child: ClipOval(
                  child: Image.asset(
                    avatarAssetPath,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Kullanıcı adı
              Text(
                username,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              // Email
              Text(
                email,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}