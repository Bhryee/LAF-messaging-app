import 'package:flutter/material.dart';

import '../services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // logout function
  void logout(){
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).primaryColor,
      child: Column(
        children: [
          DrawerHeader(child: Image.asset("media/logo.png")),

          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              title: const Text("S O H B E T"),
              leading: const Icon(Icons.messenger),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              title: const Text("P R O F İ L"),
              leading: const Icon(Icons.person),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              title: const Text("Ç I K I Ş  Y A P"),
              leading: const Icon(Icons.logout),
              onTap: logout,
            ),
          )
        ],
      ),

    );
  }
}
