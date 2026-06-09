import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_app_bar.dart';

class AdminReportDetailsScreen extends StatelessWidget {
  final String reportId;

  const AdminReportDetailsScreen({super.key, required this.reportId});

  Color getStatusColor(String status) {
    switch (status) {
      case "Open":
        return Colors.green;

      case "Pending":
        return Colors.orange;

      case "Resolved":
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(
        title: "Profile",
        subtitle: "Edit and Update Your Information",
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("reports")
            .doc(reportId)
            .get(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final userId = data["userId"];

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(userId)
                .get(),

            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const Center(child: Text("User not found"));
              }

              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),

                      child: Image.network(
                        (data["imageUrl"] ?? "").toString().isNotEmpty
                            ? data["imageUrl"]
                            : "https://picsum.photos/500",

                        height: 240,

                        width: double.infinity,

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

                    const SizedBox(height: 15),

                    Card(
                      elevation: 2,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              userData["photoUrl"] != null &&
                                  userData["photoUrl"].toString().isNotEmpty
                              ? NetworkImage(userData["photoUrl"])
                              : null,

                          child:
                              userData["photoUrl"] == null ||
                                  userData["photoUrl"].toString().isEmpty
                              ? Text(
                                  userData["fullName"]
                                      .toString()
                                      .substring(0, 1)
                                      .toUpperCase(),
                                )
                              : null,
                        ),

                        title: Text(
                          userData["fullName"] ?? "",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          mainAxisSize: MainAxisSize.min,

                          children: [
                            Text(userData["email"] ?? ""),

                            Text(userData["phone"] ?? ""),

                            Text(userData["location"] ?? ""),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.description),

                        title: const Text("Description"),

                        subtitle: Text(data["description"] ?? ""),
                      ),
                    ),

                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.category),

                        title: const Text("Category"),

                        subtitle: Text(data["category"] ?? ""),
                      ),
                    ),

                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_on),

                        title: const Text("Location"),

                        subtitle: Text(data["location"] ?? ""),
                      ),
                    ),

                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.info),

                        title: const Text("Type"),

                        subtitle: Text(
                          data["isLost"] == true ? "Lost Item" : "Found Item",
                        ),
                      ),
                    ),

                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.flag),

                        title: const Text("Status"),

                        subtitle: Text(data["status"] ?? ""),

                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),

                          decoration: BoxDecoration(
                            color: getStatusColor(data["status"] ?? ""),

                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(
                            data["status"] ?? "",

                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit),

                        label: const Text("Edit Report"),

                        onPressed: () {},
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),

                        label: const Text("Delete"),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,

                          foregroundColor: Colors.white,
                        ),

                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,

                            builder: (_) => AlertDialog(
                              title: const Text("Delete"),

                              content: const Text("Delete this report?"),

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
                                .collection("reports")
                                .doc(reportId)
                                .delete();

                            if (context.mounted) {
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Report Deleted")),
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
          );
        },
      ),
    );
  }
}
