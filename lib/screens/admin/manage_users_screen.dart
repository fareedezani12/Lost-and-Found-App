import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Users"), centerTitle: true),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search user...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var users = snapshot.data!.docs;

                users = users.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final name = (data["fullName"] ?? "")
                      .toString()
                      .toLowerCase();

                  final email = (data["email"] ?? "").toString().toLowerCase();

                  return name.contains(search) || email.contains(search);
                }).toList();

                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      "No users found",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),

                  itemCount: users.length,

                  itemBuilder: (context, index) {
                    final data = users[index].data() as Map<String, dynamic>;

                    final role = data["role"] ?? "user";

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),

                      elevation: 3,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(12),

                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,

                                  backgroundImage:
                                      data["photoUrl"] != null &&
                                          data["photoUrl"].toString().isNotEmpty
                                      ? NetworkImage(data["photoUrl"])
                                      : null,

                                  child:
                                      data["photoUrl"] == null ||
                                          data["photoUrl"].toString().isEmpty
                                      ? Text(
                                          (data["fullName"] ?? "U")
                                                  .toString()
                                                  .isNotEmpty
                                              ? data["fullName"]
                                                    .toString()
                                                    .substring(0, 1)
                                                    .toUpperCase()
                                              : "U",
                                        )
                                      : null,
                                ),

                                const SizedBox(width: 15),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        data["fullName"] ?? "",

                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(data["email"] ?? ""),

                                      Text(data["phone"] ?? ""),

                                      Text(data["location"] ?? ""),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 6,
                                  ),

                                  decoration: BoxDecoration(
                                    color: role == "admin"
                                        ? Colors.red
                                        : Colors.blue,

                                    borderRadius: BorderRadius.circular(30),
                                  ),

                                  child: Text(
                                    role.toString().toUpperCase(),

                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: "role",

                                      child: ListTile(
                                        leading: Icon(
                                          Icons.admin_panel_settings,
                                        ),

                                        title: Text("Change Role"),
                                      ),
                                    ),

                                    const PopupMenuItem(
                                      value: "delete",

                                      child: ListTile(
                                        leading: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),

                                        title: Text("Delete User"),
                                      ),
                                    ),
                                  ],

                                  onSelected: (value) async {
                                    if (value == "role") {
                                      await FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(users[index].id)
                                          .update({
                                            "role": role == "admin"
                                                ? "user"
                                                : "admin",
                                          });
                                    }

                                    if (value == "delete") {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text("Delete User"),

                                          content: const Text(
                                            "Delete this user?",
                                          ),

                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },

                                              child: const Text("Cancel"),
                                            ),

                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },

                                              child: const Text("Delete"),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(users[index].id)
                                            .delete();
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
}
