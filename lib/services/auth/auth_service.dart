import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get user
  User? getCurrentUser(){
    return _auth.currentUser;
  }

  // login
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // avatar
  Map<String, String> getAvatarOptions() {
    return {
      'avatar1': 'media/avatar1.png',
      'avatar2': 'media/avatar2.png',
      'avatar3': 'media/avatar3.png',
    };
  }


  String getAvatarAssetPath(String? avatarId) {
    final avatars = getAvatarOptions();
    return avatars[avatarId] ?? avatars['avatar1']!; // Varsayılan avatar1
  }

  // signup
  Future<UserCredential> createUserWithEmailAndPassword(
      String email,
      String password,
      {String? username, String? selectedAvatar}
      ) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password);


      String finalAvatar = selectedAvatar ?? 'avatar1';

      // Kullanıcı bilgilerini Firestore'a kaydet
      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
        "username": username ?? "",
        "selectedAvatar": finalAvatar, // Avatar ID'si (avatar1, avatar2, avatar3)
        "favorites": [], // Favori kullanıcıların UID'leri
        "createdAt": FieldValue.serverTimestamp(),
      });

      print("✅ Kullanıcı bilgileri kaydedildi - Avatar: $finalAvatar");
      return userCredential;

    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    } catch (e) {
      print("❌ Kullanıcı oluşturma hatası: $e");
      throw Exception("Kullanıcı oluşturulurken hata oluştu: $e");
    }
  }


  Future<void> addToFavorites(String favoriteUserID) async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) throw Exception("Kullanıcı bulunamadı");

      await _firestore.collection("Users").doc(currentUser.uid).update({
        "favorites": FieldValue.arrayUnion([favoriteUserID])
      });
    } catch (e) {
      throw Exception("Favorilere eklenirken hata oluştu: $e");
    }
  }


  Future<void> removeFromFavorites(String favoriteUserID) async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) throw Exception("Kullanıcı bulunamadı");

      await _firestore.collection("Users").doc(currentUser.uid).update({
        "favorites": FieldValue.arrayRemove([favoriteUserID])
      });

      print("✅ Favorilerden çıkarıldı: $favoriteUserID");
    } catch (e) {
      print("❌ Favorilerden çıkarma hatası: $e");
      throw Exception("Favorilerden çıkarılırken hata oluştu: $e");
    }
  }


  Stream<List<String>> getFavoritesStream() {
    final currentUser = getCurrentUser();
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection("Users")
        .doc(currentUser.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final favorites = data['favorites'] as List<dynamic>?;
        return favorites?.cast<String>() ?? [];
      }
      return <String>[];
    });
  }


  Future<List<String>> getFavorites() async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) return [];

      final doc = await _firestore.collection("Users").doc(currentUser.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final favorites = data['favorites'] as List<dynamic>?;
        return favorites?.cast<String>() ?? [];
      }
      return [];
    } catch (e) {
      print("❌ Favoriler getirme hatası: $e");
      return [];
    }
  }


  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection("Users").doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print("❌ Profil getirme hatası: $e");
      return null;
    }
  }

  // logout
  Future<void> signOut() async{
    await _auth.signOut();
  }
}