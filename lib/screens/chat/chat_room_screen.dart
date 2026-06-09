import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../profile/user_profile_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String title;
  final String otherUserId;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.title,
    required this.otherUserId,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  Future<void> sendMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId)
        .collection("messages")
        .add({
          "senderId": uid,
          "message": text,
          "createdAt": FieldValue.serverTimestamp(),
          "isSeen": false,
        });

    await FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId)
        .update({
          "lastMessage": text,
          "lastMessageTime": FieldValue.serverTimestamp(),
        });

    messageController.clear();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 1,

        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("chats")
              .doc(widget.chatId)
              .get(),
          builder: (context, chatSnapshot) {
            if (!chatSnapshot.hasData) {
              return const Text("Loading...");
            }

            final chatData = chatSnapshot.data!.data() as Map<String, dynamic>;

            final otherUserId = (chatData["participants"] as List).firstWhere(
              (id) => id != FirebaseAuth.instance.currentUser!.uid,
            );

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(otherUserId)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return Row(
                    children: const [
                      CircleAvatar(child: Icon(Icons.person)),
                      SizedBox(width: 10),
                      Text("Loading..."),
                    ],
                  );
                }

                final user = userSnapshot.data!.data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserProfileScreen(userId: otherUserId),
                      ),
                    );
                  },

                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,

                        backgroundImage:
                            user["photoUrl"] != null && user["photoUrl"] != ""
                            ? NetworkImage(user["photoUrl"])
                            : null,

                        child:
                            user["photoUrl"] == null || user["photoUrl"] == ""
                            ? const Icon(Icons.person)
                            : null,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              user["fullName"] ?? "User",
                              style: const TextStyle(fontSize: 17),
                            ),

                            const Text(
                              "Tap to view profile",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("chats")
                    .doc(widget.chatId)
                    .collection("messages")
                    .orderBy("createdAt")
                    .snapshots(),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!.docs;

                  for (var doc in messages) {
                    final msg = doc.data() as Map<String, dynamic>;

                    if (msg["senderId"] != uid &&
                        (msg["isSeen"] ?? false) == false) {
                      doc.reference.update({"isSeen": true});
                    }
                  }

                  if (messages.isEmpty) {
                    return const Center(
                      child: Text(
                        "Start your conversation 👋",
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (scrollController.hasClients) {
                      scrollController.jumpTo(
                        scrollController.position.maxScrollExtent,
                      );
                    }
                  });

                  return ListView.builder(
                    controller: scrollController,

                    padding: const EdgeInsets.all(12),

                    itemCount: messages.length,

                    itemBuilder: (context, index) {
                      final data =
                          messages[index].data() as Map<String, dynamic>;

                      final isMe = data["senderId"] == uid;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,

                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 280),

                          margin: const EdgeInsets.only(bottom: 10),

                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey.shade200,

                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),

                              topRight: const Radius.circular(18),

                              bottomLeft: Radius.circular(isMe ? 18 : 0),

                              bottomRight: Radius.circular(isMe ? 0 : 18),
                            ),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    data["message"],
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    data["createdAt"] == null
                                        ? ""
                                        : TimeOfDay.fromDateTime(
                                            (data["createdAt"] as Timestamp)
                                                .toDate(),
                                          ).format(context),

                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white70
                                          : Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 5),

                              if (isMe)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      (data["isSeen"] ?? false)
                                          ? Icons.done_all
                                          : Icons.done,
                                      size: 16,
                                      color: (data["isSeen"] ?? false)
                                          ? Colors.lightBlueAccent
                                          : Colors.white70,
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

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

              decoration: const BoxDecoration(color: Colors.white),

              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,

                      decoration: InputDecoration(
                        hintText: "Type a message",

                        filled: true,

                        fillColor: Colors.grey.shade200,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),

                          borderSide: BorderSide.none,
                        ),
                      ),

                      onSubmitted: (_) {
                        sendMessage();
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xff1565C0),
                      shape: BoxShape.circle,
                    ),

                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),

                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
