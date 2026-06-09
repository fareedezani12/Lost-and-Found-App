import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_claim_details_screen.dart';
import '../../widgets/custom_app_bar.dart';

class ManageClaimsScreen extends StatefulWidget {
  const ManageClaimsScreen({super.key});

  @override
  State<ManageClaimsScreen> createState() => _ManageClaimsScreenState();
}

class _ManageClaimsScreenState extends State<ManageClaimsScreen> {
  String search = "";

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
        title: "Manage Claims",
        subtitle: "Review all claim requests",
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search claim...",
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

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("claims")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var claims = snapshot.data!.docs;

                claims = claims.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final title = (data["title"] ?? "").toString().toLowerCase();

                  final claimer = (data["claimerName"] ?? "")
                      .toString()
                      .toLowerCase();

                  return title.contains(search) || claimer.contains(search);
                }).toList();

                if (claims.isEmpty) {
                  return const Center(child: Text("No Claims Found"));
                }

                return ListView.builder(
                  itemCount: claims.length,

                  itemBuilder: (context, index) {
                    final data = claims[index].data() as Map<String, dynamic>;

                    final status = data["status"] ?? "Pending";

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),

                      elevation: 3,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(15),

                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 35,

                                  backgroundImage:
                                      (data["imageUrl"] ?? "")
                                          .toString()
                                          .isNotEmpty
                                      ? NetworkImage(data["imageUrl"])
                                      : null,

                                  child:
                                      (data["imageUrl"] ?? "")
                                          .toString()
                                          .isEmpty
                                      ? const Icon(Icons.inventory, size: 35)
                                      : null,
                                ),

                                const SizedBox(width: 15),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        data["title"] ?? "",

                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        "Claimer : ${data["claimerName"] ?? "-"}",
                                      ),

                                      Text(data["claimerEmail"] ?? ""),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            Align(
                              alignment: Alignment.centerLeft,

                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 6,
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
                                              AdminClaimDetailsScreen(
                                                claimId: claims[index].id,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(width: 10),

                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == "approve") {
                                      await FirebaseFirestore.instance
                                          .collection("claims")
                                          .doc(claims[index].id)
                                          .update({"status": "Approved"});
                                    }

                                    if (value == "reject") {
                                      await FirebaseFirestore.instance
                                          .collection("claims")
                                          .doc(claims[index].id)
                                          .update({"status": "Rejected"});
                                    }

                                    if (value == "delete") {
                                      await FirebaseFirestore.instance
                                          .collection("claims")
                                          .doc(claims[index].id)
                                          .delete();
                                    }
                                  },

                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: "approve",
                                      child: Text("Approve"),
                                    ),

                                    const PopupMenuItem(
                                      value: "reject",
                                      child: Text("Reject"),
                                    ),

                                    const PopupMenuItem(
                                      value: "delete",
                                      child: Text("Delete"),
                                    ),
                                  ],
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
        ],
      ),
    );
  }
}
