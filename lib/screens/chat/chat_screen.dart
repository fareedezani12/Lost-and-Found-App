import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_app_bar.dart';

import 'chat_room_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  String formatTime(BuildContext context, Timestamp? timestamp) {
    if (timestamp == null) return "";

    final date = timestamp.toDate();
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);

    final difference = today.difference(messageDay).inDays;

    if (difference == 0) {
      return TimeOfDay.fromDateTime(date).format(context);
    }

    if (difference == 1) {
      return "Yesterday";
    }

    if (difference < 7) {
      const days = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday",
      ];

      return days[date.weekday - 1];
    }

    return "${date.day}/${date.month}";
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
            .orderBy("lastMessageTime", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
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

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "📦 ${data["title"] ?? "Unknown Item"}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            data["lastSenderId"] == uid
                                ? "You: ${data["lastMessage"] ?? ""}"
                                : data["lastMessage"] ?? "Start chatting...",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      trailing: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("chats")
                            .doc(chats[index].id)
                            .collection("messages")
                            .where("senderId", isNotEqualTo: uid)
                            .where("isSeen", isEqualTo: false)
                            .snapshots(),

                        builder: (context, unreadSnapshot) {
                          final unreadCount = unreadSnapshot.hasData
                              ? unreadSnapshot.data!.docs.length
                              : 0;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatTime(context, data["lastMessageTime"]),
                                style: const TextStyle(fontSize: 12),
                              ),

                              const SizedBox(height: 4),

                              if (unreadCount > 0)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
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
