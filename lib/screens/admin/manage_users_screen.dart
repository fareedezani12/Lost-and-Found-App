import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Users")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text("No Users"));
          }

          return ListView.builder(
            itemCount: users.length,

            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;

              final role = data["role"] ?? "user";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      (data["fullName"] ?? "U").toString()[0].toUpperCase(),
                    ),
                  ),

                  title: Text(data["fullName"] ?? ""),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(data["email"] ?? ""),

                      const SizedBox(height: 5),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),

                        decoration: BoxDecoration(
                          color: role == "admin" ? Colors.red : Colors.blue,

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Text(
                          role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  trailing: ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(users[index].id)
                          .update({"role": role == "admin" ? "user" : "admin"});
                    },

                    child: Text(role == "admin" ? "Make User" : "Make Admin"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
