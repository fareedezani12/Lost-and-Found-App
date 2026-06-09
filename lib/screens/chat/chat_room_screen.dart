import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../profile/user_profile_screen.dart';
import '../../models/report_model.dart';
import '../report/report_details_screen.dart';

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

  String getDateLabel(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final yesterday = today.subtract(const Duration(days: 1));

    final messageDay = DateTime(date.year, date.month, date.day);

    if (messageDay == today) {
      return "Today";
    }

    if (messageDay == yesterday) {
      return "Yesterday";
    }

    return "${date.day}/${date.month}/${date.year}";
  }

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
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == "report") {
                final chatDoc = await FirebaseFirestore.instance
                    .collection("chats")
                    .doc(widget.chatId)
                    .get();

                final chatData = chatDoc.data()!;

                final reportId = chatData["reportId"];

                final reportDoc = await FirebaseFirestore.instance
                    .collection("reports")
                    .doc(reportId)
                    .get();

                if (!reportDoc.exists) return;

                final report = ReportModel.fromFirestore(
                  reportDoc.id,
                  reportDoc.data()!,
                );

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportDetailsScreen(report: report),
                    ),
                  );
                }
              }

              if (value == "block") {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),

                  builder: (_) {
                    return Padding(
                      padding: const EdgeInsets.all(20),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Container(
                            width: 60,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.block,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            "Block User",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "After blocking this user:\n\n"
                            "• You will no longer receive messages.\n"
                            "• This chat will be hidden.\n"
                            "• You can unblock later from Settings.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15),
                          ),

                          const SizedBox(height: 25),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),

                                  onPressed: () {
                                    Navigator.pop(context);
                                  },

                                  child: const Text("Cancel"),
                                ),
                              ),

                              const SizedBox(width: 15),

                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.block),

                                  label: const Text("Block"),

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),

                                  onPressed: () async {
                                    final chatDoc = await FirebaseFirestore
                                        .instance
                                        .collection("chats")
                                        .doc(widget.chatId)
                                        .get();

                                    final chatData = chatDoc.data()!;

                                    final otherUserId =
                                        (chatData["participants"] as List)
                                            .firstWhere(
                                              (id) =>
                                                  id !=
                                                  FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .uid,
                                            );

                                    await FirebaseFirestore.instance
                                        .collection("blocked_users")
                                        .add({
                                          "blockerId": FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid,

                                          "blockedId": otherUserId,

                                          "createdAt":
                                              FieldValue.serverTimestamp(),
                                        });

                                    Navigator.pop(context);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "User blocked successfully.",
                                          ),
                                        ),
                                      );

                                      Navigator.pop(
                                        context,
                                      ); // keluar dari chat
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                );
              }

              if (value == "reportUser") {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),

                  builder: (_) {
                    String selectedReason = "";

                    return StatefulBuilder(
                      builder: (context, setModalState) {
                        return Padding(
                          padding: const EdgeInsets.all(20),

                          child: Column(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              Container(
                                width: 60,
                                height: 5,

                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Icon(
                                Icons.flag_circle,
                                size: 60,
                                color: Colors.orange,
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "Report User",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              const Text(
                                "Select a reason for reporting this user.",
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 20),

                              RadioListTile(
                                value: "Fake Claim",
                                groupValue: selectedReason,

                                title: const Text("Fake Claim"),

                                secondary: const Icon(Icons.assignment_late),

                                onChanged: (value) {
                                  setModalState(() {
                                    selectedReason = value!;
                                  });
                                },
                              ),

                              RadioListTile(
                                value: "Spam",
                                groupValue: selectedReason,

                                title: const Text("Spam"),

                                secondary: const Icon(Icons.sms_failed),

                                onChanged: (value) {
                                  setModalState(() {
                                    selectedReason = value!;
                                  });
                                },
                              ),

                              RadioListTile(
                                value: "Harassment",
                                groupValue: selectedReason,

                                title: const Text("Harassment"),

                                secondary: const Icon(Icons.warning),

                                onChanged: (value) {
                                  setModalState(() {
                                    selectedReason = value!;
                                  });
                                },
                              ),

                              RadioListTile(
                                value: "Scam",
                                groupValue: selectedReason,

                                title: const Text("Scam"),

                                secondary: const Icon(Icons.gpp_bad),

                                onChanged: (value) {
                                  setModalState(() {
                                    selectedReason = value!;
                                  });
                                },
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,

                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.flag),

                                  label: const Text("Submit Report"),

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),

                                  onPressed: () async {
                                    if (selectedReason.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please select a reason.",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final chatDoc = await FirebaseFirestore
                                        .instance
                                        .collection("chats")
                                        .doc(widget.chatId)
                                        .get();

                                    final chatData = chatDoc.data()!;

                                    final otherUserId =
                                        (chatData["participants"] as List)
                                            .firstWhere(
                                              (id) =>
                                                  id !=
                                                  FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .uid,
                                            );

                                    await FirebaseFirestore.instance
                                        .collection("user_reports")
                                        .add({
                                          "reporterId": FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid,

                                          "reportedUserId": otherUserId,

                                          "chatId": widget.chatId,

                                          "reason": selectedReason,

                                          "status": "Pending",

                                          "createdAt":
                                              FieldValue.serverTimestamp(),
                                        });

                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Report submitted successfully.",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },

            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "report",
                child: ListTile(
                  leading: Icon(Icons.description),
                  title: Text("View Report"),
                ),
              ),

              const PopupMenuItem(
                value: "block",
                child: ListTile(
                  leading: Icon(Icons.block),
                  title: Text("Block User"),
                ),
              ),

              const PopupMenuItem(
                value: "reportUser",
                child: ListTile(
                  leading: Icon(Icons.flag),
                  title: Text("Report User"),
                ),
              ),
            ],
          ),
        ],
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

                      final currentDate = data["createdAt"] == null
                          ? DateTime.now()
                          : (data["createdAt"] as Timestamp).toDate();

                      bool showDate = false;

                      if (index == 0) {
                        showDate = true;
                      } else {
                        final previous =
                            messages[index - 1].data() as Map<String, dynamic>;

                        final previousDate = previous["createdAt"] == null
                            ? DateTime.now()
                            : (previous["createdAt"] as Timestamp).toDate();

                        showDate =
                            currentDate.day != previousDate.day ||
                            currentDate.month != previousDate.month ||
                            currentDate.year != previousDate.year;
                      }

                      return Column(
                        children: [
                          if (showDate)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    getDateLabel(currentDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,

                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 280),

                              margin: const EdgeInsets.only(bottom: 10),

                              padding: const EdgeInsets.all(14),

                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.blue
                                    : Colors.grey.shade200,

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
                                          color: isMe
                                              ? Colors.white
                                              : Colors.black,
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
                          ),
                        ],
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
