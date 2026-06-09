import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_report_details_screen.dart';
import '../../widgets/custom_app_bar.dart';

class AdminClaimDetailsScreen extends StatelessWidget {
  final String claimId;

  const AdminClaimDetailsScreen({super.key, required this.claimId});

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
      appBar: const CustomHeader(
        title: "Explore",
        subtitle: "Find Your Lost Item Here",
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("claims")
            .doc(claimId)
            .get(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final status = data["status"] ?? "Pending";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: Image.network(
                    (data["imageUrl"] ?? "").toString().isNotEmpty
                        ? data["imageUrl"]
                        : "https://picsum.photos/500",

                    width: double.infinity,

                    height: 230,

                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  data["title"] ?? "",

                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),

                    title: const Text("Claimer"),

                    subtitle: Text(data["claimerName"] ?? ""),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email),

                    title: const Text("Email"),

                    subtitle: Text(data["claimerEmail"] ?? ""),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.flag),

                    title: const Text("Status"),

                    subtitle: Text(status),

                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: getStatusColor(status),

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        status,

                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.visibility),

                    label: const Text("View Original Report"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),

                    onPressed: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => AdminReportDetailsScreen(
                            reportId: data["reportId"],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),

                    label: const Text("Delete Claim"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),

                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,

                        builder: (_) => AlertDialog(
                          title: const Text("Delete Claim"),

                          content: const Text(
                            "Are you sure you want to delete this claim?",
                          ),

                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },

                              child: const Text("Cancel"),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },

                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await FirebaseFirestore.instance
                            .collection("claims")
                            .doc(claimId)
                            .delete();

                        if (context.mounted) {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Claim deleted successfully"),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
