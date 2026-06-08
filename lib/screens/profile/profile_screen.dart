import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [
                const SizedBox(height: 20),

                const CircleAvatar(
                  radius: 60,
                  child: Icon(Icons.person, size: 60),
                ),

                const SizedBox(height: 20),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Full Name"),
                    subtitle: Text(data["fullName"] ?? ""),
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text("Email"),
                    subtitle: Text(data["email"] ?? ""),
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text("Phone"),
                    subtitle: Text(data["phone"] ?? ""),
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text("Location"),
                    subtitle: Text(data["location"] ?? ""),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),

                    label: const Text("Logout"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),

                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Logout"),
                          content: const Text(
                            "Are you sure you want to logout?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: const Text("No"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: const Text("Yes"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await FirebaseAuth.instance.signOut();

                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
