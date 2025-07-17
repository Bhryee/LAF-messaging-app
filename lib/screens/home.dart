import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laf_app/screens/chat.dart';
import 'package:laf_app/services/auth/auth_service.dart';
import 'package:laf_app/services/chat/chat_service.dart';
import 'package:laf_app/widgets/profile_image.dart';

import '../widgets/drawer.dart';
import '../widgets/user_list_tile.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("LAFLAMALARIM"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: const UserProfileWidget(
                showUsername: false,
                avatarRadius: 20,
              ),
            ),
          ),
        ],
      ),
      drawer: const MyDrawer(),

      body: Column(
        children: [
          // Favori alan - Sabit yükseklik
          Container(height: 130, child: _buildFavoritesSection(context)),

          // Divider
          Divider(height: 1, color: Colors.grey[300]),

          // User listesi - Kalan alan
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  // Fav people
  Widget _buildFavoritesSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  color: Color(0xFF71503D),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "Favori Kişilerim",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Horizontal scrollable list
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: _authService.getFavoritesStream(),
              builder: (context, favoritesSnapshot) {
                if (favoritesSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final favoriteUIDs = favoritesSnapshot.data ?? [];

                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _chatService.getUserStream(),
                  builder: (context, usersSnapshot) {
                    if (usersSnapshot.hasError || usersSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final users = usersSnapshot.data ?? [];
                    final currentUser = _authService.getCurrentUser();
                    if (currentUser == null) return const SizedBox.shrink();

                    final currentUserEmail = currentUser.email;
                    final currentUserUID = currentUser.uid;


                    final otherUsers = users.where((user) {
                      final userEmail = user["email"];
                      final userUID = user["uid"];
                      return (userEmail != currentUserEmail) && (userUID != currentUserUID);
                    }).toList();


                    final favoriteUsers = otherUsers.where((user) =>
                        favoriteUIDs.contains(user["uid"])
                    ).toList();

                    return ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [

                        _buildAddFavoriteButton(context, otherUsers, favoriteUIDs),


                        ...favoriteUsers.map((userData) => _buildFavoriteItem(userData, context)).toList(),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAddFavoriteButton(BuildContext context, List<Map<String, dynamic>> allUsers, List<String> favoriteUIDs) {
    return GestureDetector(
      onTap: () => _showAddFavoriteDialog(context, allUsers, favoriteUIDs),
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [


            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF866859),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(height: 8),


            const Text(
              "Ekle",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


  void _showAddFavoriteDialog(BuildContext context, List<Map<String, dynamic>> allUsers, List<String> favoriteUIDs) {

    final nonFavoriteUsers = allUsers.where((user) =>
    !favoriteUIDs.contains(user["uid"])
    ).toList();

    TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredUsers = List.from(nonFavoriteUsers);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [

                    // Search Bar
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            if (value.isEmpty) {
                              filteredUsers = List.from(nonFavoriteUsers);
                            } else {
                              filteredUsers = nonFavoriteUsers.where((user) {
                                final username = user['username'] ?? user['email'] ?? '';
                                return username.toLowerCase().contains(value.toLowerCase());
                              }).toList();
                            }
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Bir ad aratın...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          hintStyle: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),

                    // User List
                    Expanded(
                      child: filteredUsers.isEmpty
                          ? const Center(
                        child: Text(
                          'Kullanıcı bulunamadı',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final userData = filteredUsers[index];
                          final username = userData['username'] ?? userData['email'] ?? 'Kullanıcı';
                          final selectedAvatar = userData['selectedAvatar'] ?? 'avatar1';
                          final avatarAssetPath = _authService.getAvatarAssetPath(selectedAvatar);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                // Heart Icon
                                GestureDetector(
                                  onTap: () async {
                                    await _addToFavorites(userData["uid"]);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFD0C4BB),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.favorite_border,
                                      color: Color(0xFF71503D),
                                      size: 20,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 15),

                                // Avatar
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey[300],
                                  child: ClipOval(
                                    child: Image.asset(
                                      avatarAssetPath,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Text(
                                          username.substring(0, 1).toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 15),

                                // User Info
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),

                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Future<void> _addToFavorites(String userID) async {
    try {
      await _authService.addToFavorites(userID);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorilere eklendi!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }


  Future<void> _removeFromFavorites(String userID) async {
    try {
      await _authService.removeFromFavorites(userID);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorilerden çıkarıldı!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }


  Widget _buildFavoriteItem(Map<String, dynamic> userData, BuildContext context) {
    final username = userData['username'] ?? userData['email'] ?? 'Kullanıcı';
    final selectedAvatar = userData['selectedAvatar'] ?? 'avatar1';
    final avatarAssetPath = _authService.getAvatarAssetPath(selectedAvatar);

    return GestureDetector(
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiveremail: userData["email"],
              receiverID: userData["uid"],
              receiverUsername: userData["username"] ?? userData["email"],
              receiverAvatar: userData["selectedAvatar"],
            ),
          ),
        );
      },
      onLongPress: () {

        _showRemoveFavoriteDialog(context, userData);
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            // Profil resmi
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[300],
              child: ClipOval(
                child: Image.asset(
                  avatarAssetPath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),


            Text(
              username.length > 8 ? "${username.substring(0, 8)}..." : username,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveFavoriteDialog(BuildContext context, Map<String, dynamic> userData) {
    final username = userData['username'] ?? userData['email'] ?? 'Kullanıcı';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Favorilerden Çıkar'),
          content: Text('$username kişisini favorilerden çıkarmak istiyor musunuz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _removeFromFavorites(userData["uid"]);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Çıkar'),
            ),
          ],
        );
      },
    );
  }


  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Hata");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading..");
        }

        final currentUser = _authService.getCurrentUser();
        if (currentUser == null) return const Text("Kullanıcı bulunamadı");

        final currentUserEmail = currentUser.email;
        final currentUserUID = currentUser.uid;

        final otherUsers = snapshot.data!.where((userData) {
          final userEmail = userData["email"];
          final userUID = userData["uid"];
          return (userEmail != currentUserEmail) && (userUID != currentUserUID);
        }).toList();

        if (otherUsers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Henüz başka kullanıcı yok",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "Yeni kullanıcılar kaydolduğunda burada görünecek",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView(
          children: otherUsers
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    return UserListTile(
      text: userData["username"] ?? userData["email"],
      selectedAvatar: userData["selectedAvatar"],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiveremail: userData["email"],
              receiverID: userData["uid"],
              receiverUsername: userData["username"] ?? userData["email"],
              receiverAvatar: userData["selectedAvatar"],
            ),
          ),
        );
      },
    );
  }
}