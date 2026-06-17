import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyClaimsScreen extends StatelessWidget {
  const MyClaimsScreen({super.key});

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

  IconData getStatusIcon(String status) {
    switch (status) {
      case "Approved":
        return Icons.check_circle;

      case "Rejected":
        return Icons.cancel;

      default:
        return Icons.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Claims")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("claims")
            .where("claimerId", isEqualTo: uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final claims = snapshot.data!.docs;

          if (claims.isEmpty) {
            return const Center(child: Text("No claim requests yet"));
          }

          return ListView.builder(
            itemCount: claims.length,

            itemBuilder: (context, index) {
              final data = claims[index].data() as Map<String, dynamic>;

              final status = data["status"] ?? "Pending";

              return Card(
                margin: const EdgeInsets.all(12),

                elevation: 3,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: getStatusColor(status),

                    child: Icon(getStatusIcon(status), color: Colors.white),
                  ),

                  title: Text(data["title"] ?? ""),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const SizedBox(height: 5),

                      Text("Status : $status"),

                      Text("Owner : ${data["ownerName"] ?? "-"}"),
                    ],
                  ),

                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
