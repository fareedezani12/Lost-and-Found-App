import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      appBar: AppBar(title: const Text("Chats")),

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

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                child: ListTile(
                  leading: const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.chat),
                  ),

                  title: Text(
                    data["title"] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
