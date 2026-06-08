import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String title;

  const ChatRoomScreen({super.key, required this.chatId, required this.title});

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
      appBar: AppBar(centerTitle: true, title: Text(widget.title)),

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
                              Text(
                                data["message"],
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                ),
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

                  CircleAvatar(
                    radius: 26,

                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),

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
