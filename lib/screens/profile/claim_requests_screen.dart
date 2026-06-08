import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClaimRequestsScreen extends StatelessWidget {
  const ClaimRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Claim Requests")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("claims")
            .where("ownerId", isEqualTo: uid)
            .where("status", isEqualTo: "Pending")
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Claim Requests"));
          }

          final claims = snapshot.data!.docs;

          return ListView.builder(
            itemCount: claims.length,
            itemBuilder: (context, index) {
              final data = claims[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 5,
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          data["imageUrl"],
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(Icons.image, size: 60),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        data["title"],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(width: 8),
                          Expanded(child: Text(data["claimerName"])),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.email),
                          const SizedBox(width: 8),
                          Expanded(child: Text(data["claimerEmail"])),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Pending",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text("Approve"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                // Update claim status
                                await FirebaseFirestore.instance
                                    .collection("claims")
                                    .doc(claims[index].id)
                                    .update({"status": "Approved"});

                                // Update report status
                                await FirebaseFirestore.instance
                                    .collection("reports")
                                    .doc(data["reportId"])
                                    .update({"status": "Resolved"});

                                await FirebaseFirestore.instance
                                    .collection("notifications")
                                    .add({
                                      "userId": data["claimerId"],

                                      "title": "Claim Approved",

                                      "message":
                                          "Your claim for '${data["title"]}' has been approved.",

                                      "isRead": false,

                                      "createdAt": FieldValue.serverTimestamp(),
                                    });

                                // Check if chat already exists
                                final existingChat = await FirebaseFirestore
                                    .instance
                                    .collection("chats")
                                    .where(
                                      "reportId",
                                      isEqualTo: data["reportId"],
                                    )
                                    .get();

                                if (existingChat.docs.isEmpty) {
                                  await FirebaseFirestore.instance
                                      .collection("chats")
                                      .add({
                                        "reportId": data["reportId"],
                                        "title": data["title"],
                                        "participants": [
                                          data["ownerId"],
                                          data["claimerId"],
                                        ],

                                        "lastMessage": "",

                                        "lastMessageTime":
                                            FieldValue.serverTimestamp(),

                                        "createdAt":
                                            FieldValue.serverTimestamp(),
                                      });
                                }

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Claim Approved & Chat Created",
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.close),
                              label: const Text("Reject"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection("claims")
                                    .doc(claims[index].id)
                                    .update({"status": "Rejected"});

                                await FirebaseFirestore.instance
                                    .collection("reports")
                                    .doc(data["reportId"])
                                    .update({"status": "Open"});

                                await FirebaseFirestore.instance
                                    .collection("notifications")
                                    .add({
                                      "userId": data["claimerId"],

                                      "title": "Claim Rejected",

                                      "message":
                                          "Your claim for '${data["title"]}' has been rejected.",

                                      "isRead": false,

                                      "createdAt": FieldValue.serverTimestamp(),
                                    });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Claim Rejected"),
                                  ),
                                );
                              },
                            ),
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
    );
  }
}
