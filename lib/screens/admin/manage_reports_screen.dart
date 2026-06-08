import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageReportsScreen extends StatelessWidget {
  const ManageReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Reports")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("reports")
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          if (reports.isEmpty) {
            return const Center(child: Text("No Reports Found"));
          }

          return ListView.builder(
            itemCount: reports.length,

            itemBuilder: (context, index) {
              final data = reports[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      data["isLost"] == true
                          ? Icons.search_off
                          : Icons.check_circle,
                    ),
                  ),

                  title: Text(data["title"] ?? ""),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(data["location"] ?? ""),

                      const SizedBox(height: 5),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),

                        decoration: BoxDecoration(
                          color: data["isLost"] == true
                              ? Colors.red
                              : Colors.green,

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Text(
                          data["isLost"] == true ? "LOST" : "FOUND",

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
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
                            title: const Text("Delete Report"),

                            content: const Text("Are you sure?"),

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
                            .collection("reports")
                            .doc(reports[index].id)
                            .delete();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Report Deleted")),
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
