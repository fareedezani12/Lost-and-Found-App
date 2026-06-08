import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageClaimsScreen extends StatelessWidget {
  const ManageClaimsScreen({super.key});

  Color getStatusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;

      case "Rejected":
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Claims")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("claims")
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final claims = snapshot.data!.docs;

          if (claims.isEmpty) {
            return const Center(child: Text("No Claims Found"));
          }

          return ListView.builder(
            itemCount: claims.length,

            itemBuilder: (context, index) {
              final data = claims[index].data() as Map<String, dynamic>;

              final status = data["status"] ?? "Pending";

              return Card(
                margin: const EdgeInsets.all(10),

                elevation: 3,

                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: getStatusColor(status),

                    child: const Icon(Icons.assignment, color: Colors.white),
                  ),

                  title: Text(data["title"] ?? "Unknown Report"),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const SizedBox(height: 5),

                      Text("Claimer: ${data["claimerName"] ?? "-"}"),

                      Text("Email: ${data["claimerEmail"] ?? "-"}"),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),

                        decoration: BoxDecoration(
                          color: getStatusColor(status),

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Text(
                          status,

                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),

                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,

                        builder: (_) {
                          return AlertDialog(
                            title: const Text("Delete Claim"),

                            content: const Text("Delete this claim?"),

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
                          );
                        },
                      );

                      if (confirm == true) {
                        await FirebaseFirestore.instance
                            .collection("claims")
                            .doc(claims[index].id)
                            .delete();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Claim Deleted")),
                          );
                        }
                      }
                    },
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
