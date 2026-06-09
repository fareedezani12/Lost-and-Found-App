import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_app_bar.dart';

import 'chat_room_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";

    final date = timestamp.toDate();

    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: const CustomHeader(
        title: "Chats",
        subtitle: "List of your Chats",
        showBackButton: false,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("chats")
            .where("participants", arrayContains: uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Chats Yet"));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,

            itemBuilder: (context, index) {
              final data = chats[index].data() as Map<String, dynamic>;

              final currentUid = FirebaseAuth.instance.currentUser!.uid;

              final otherUserId = (data["participants"] as List).firstWhere(
                (id) => id != currentUid,
              );

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("blocked_users")
                    .where("blockerId", isEqualTo: currentUid)
                    .where("blockedId", isEqualTo: otherUserId)
                    .get(),

                builder: (context, blockedSnapshot) {
                  if (!blockedSnapshot.hasData) {
                    return const SizedBox();
                  }

                  if (blockedSnapshot.data!.docs.isNotEmpty) {
                    return const SizedBox();
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    child: ListTile(
                      leading: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(otherUserId)
                            .get(),

                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const CircleAvatar(
                              child: Icon(Icons.person),
                            );
                          }

                          final userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;

                          return CircleAvatar(
                            backgroundImage:
                                userData["photoUrl"] != null &&
                                    userData["photoUrl"] != ""
                                ? NetworkImage(userData["photoUrl"])
                                : null,

                            child:
                                userData["photoUrl"] == null ||
                                    userData["photoUrl"] == ""
                                ? const Icon(Icons.person)
                                : null,
                          );
                        },
                      ),

                      title: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(otherUserId)
                            .get(),

                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const Text("Loading...");
                          }

                          final user =
                              userSnapshot.data!.data() as Map<String, dynamic>;

                          return Text(
                            user["fullName"] ?? "User",

                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),

                      subtitle: Text(
                        data["lastMessage"] ?? "No messages",

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,
                      ),

                      trailing: Text(
                        formatTime(data["lastMessageTime"]),

                        style: const TextStyle(fontSize: 12),
                      ),

                      onTap: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) => ChatRoomScreen(
                              chatId: chats[index].id,

                              title: data["title"],

                              otherUserId: otherUserId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
