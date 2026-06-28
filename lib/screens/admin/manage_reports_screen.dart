import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_report_details_screen.dart';
import '../../widgets/custom_app_bar.dart';

class ManageReportsScreen extends StatefulWidget {
  const ManageReportsScreen({super.key});

  @override
  State<ManageReportsScreen> createState() => _ManageReportsScreenState();
}

class _ManageReportsScreenState extends State<ManageReportsScreen> {
  String search = "";
  String filter = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(
        title: "Manage Reports",
        subtitle: "View and manage all reports",
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),

            child: TextField(
              decoration: InputDecoration(
                hintText: "Search reports...",

                prefixIcon: const Icon(Icons.search),

                filled: true,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),

                  borderSide: BorderSide.none,
                ),
              ),

              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),

            child: Row(
              children: [
                ChoiceChip(
                  label: const Text("All"),
                  selected: filter == "All",
                  onSelected: (_) {
                    setState(() {
                      filter = "All";
                    });
                  },
                ),

                const SizedBox(width: 10),

                ChoiceChip(
                  label: const Text("Lost"),
                  selected: filter == "Lost",
                  onSelected: (_) {
                    setState(() {
                      filter = "Lost";
                    });
                  },
                ),

                const SizedBox(width: 10),

                ChoiceChip(
                  label: const Text("Found"),
                  selected: filter == "Found",
                  onSelected: (_) {
                    setState(() {
                      filter = "Found";
                    });
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("reports")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var reports = snapshot.data!.docs;

                reports = reports.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final title = (data["title"] ?? "").toString().toLowerCase();

                  final location = (data["location"] ?? "")
                      .toString()
                      .toLowerCase();

                  final category = (data["category"] ?? "")
                      .toString()
                      .toLowerCase();

                  return title.contains(search) ||
                      location.contains(search) ||
                      category.contains(search);
                }).toList();

                if (filter == "Lost") {
                  reports = reports.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data["isLost"] == true;
                  }).toList();
                }

                if (filter == "Found") {
                  reports = reports.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data["isLost"] == false;
                  }).toList();
                }

                if (reports.isEmpty) {
                  return const Center(child: Text("No Reports Found"));
                }

                return ListView.builder(
                  itemCount: reports.length,

                  itemBuilder: (context, index) {
                    final data = reports[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),

                      elevation: 3,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18),
                                ),

                                child: Image.network(
                                  (data["imageUrl"] ?? "").toString().isNotEmpty
                                      ? data["imageUrl"]
                                      : "https://picsum.photos/500",

                                  width: double.infinity,

                                  height: 180,

                                  fit: BoxFit.cover,
                                ),
                              ),

                              Positioned(
                                top: 10,
                                right: 10,

                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),

                                  decoration: BoxDecoration(
                                    color: data["isLost"] == true
                                        ? Colors.red
                                        : Colors.green,

                                    borderRadius: BorderRadius.circular(30),
                                  ),

                                  child: Text(
                                    data["isLost"] == true ? "LOST" : "FOUND",

                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.all(15),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  data["title"] ?? "",

                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 18,
                                      color: Colors.grey,
                                    ),

                                    const SizedBox(width: 5),

                                    Text(data["location"] ?? ""),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.category,
                                      size: 18,
                                      color: Colors.grey,
                                    ),

                                    const SizedBox(width: 5),

                                    Text(data["category"] ?? ""),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: Colors.grey,
                                    ),

                                    const SizedBox(width: 5),

                                    Text(
                                      data["createdAt"] == null
                                          ? "-"
                                          : (data["createdAt"] as Timestamp)
                                                .toDate()
                                                .toString()
                                                .substring(0, 16),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),

                                  decoration: BoxDecoration(
                                    color: data["status"] == "Open"
                                        ? Colors.green
                                        : data["status"] == "Pending"
                                        ? Colors.orange
                                        : Colors.blue,

                                    borderRadius: BorderRadius.circular(30),
                                  ),

                                  child: Text(
                                    data["status"] ?? "",

                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 15),

                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.visibility),

                                        label: const Text("View Details"),

                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  AdminReportDetailsScreen(
                                                    reportId: reports[index].id,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    PopupMenuButton(
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                          value: "delete",
                                          child: ListTile(
                                            leading: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            title: Text("Delete"),
                                          ),
                                        ),
                                      ],

                                      onSelected: (value) async {
                                        if (value == "delete") {
                                          final confirm =
                                              await showDialog<bool>(
                                                context: context,

                                                builder: (_) => AlertDialog(
                                                  title: const Text(
                                                    "Delete Report",
                                                  ),

                                                  content: const Text(
                                                    "Delete this report?",
                                                  ),

                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        );
                                                      },

                                                      child: const Text(
                                                        "Cancel",
                                                      ),
                                                    ),

                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        );
                                                      },

                                                      child: const Text(
                                                        "Delete",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                          if (confirm == true) {
                                            await FirebaseFirestore.instance
                                                .collection("reports")
                                                .doc(reports[index].id)
                                                .delete();
                                          }
                                        }
                                      },
                                    ),
                                  ],
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
        ],
      ),
    );
  }
}
