import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/report_model.dart';
import '../../providers/report_provider.dart';
import '../../widgets/item_card.dart';
import '../report/add_report_screen.dart';
import '../report/report_details_screen.dart';
import '../notifications/notification_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                  ),

                  borderRadius: BorderRadius.circular(25),
                ),

                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),

                  builder: (context, snapshot) {
                    String username = "User";

                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;

                      username = data["fullName"] ?? "User";
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .snapshots(),

                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircleAvatar(
                                    radius: 25,
                                    child: Icon(Icons.person),
                                  );
                                }

                                final data =
                                    snapshot.data!.data()
                                        as Map<String, dynamic>?;

                                return CircleAvatar(
                                  radius: 25,

                                  backgroundImage:
                                      data?["photoUrl"] != null &&
                                          data?["photoUrl"] != ""
                                      ? NetworkImage(data!["photoUrl"])
                                      : null,

                                  child:
                                      data?["photoUrl"] == null ||
                                          data?["photoUrl"] == ""
                                      ? const Icon(Icons.person)
                                      : null,
                                );
                              },
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  const Text(
                                    "Welcome Back 👋",
                                    style: TextStyle(color: Colors.white70),
                                  ),

                                  Text(
                                    username,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("notifications")
                                  .where(
                                    "userId",
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser!.uid,
                                  )
                                  .where("isRead", isEqualTo: false)
                                  .snapshots(),

                              builder: (context, snapshot) {
                                final unread = snapshot.hasData
                                    ? snapshot.data!.docs.length
                                    : 0;

                                return Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.white,

                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.notifications,
                                          color: Color(0xff1565C0),
                                        ),

                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const NotificationScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    if (unread > 0)
                                      Positioned(
                                        right: 0,
                                        top: 0,

                                        child: Container(
                                          padding: const EdgeInsets.all(4),

                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),

                                          child: Text(
                                            unread.toString(),

                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          onChanged: (value) {
                            setState(() {
                              searchText = value.toLowerCase();
                            });
                          },

                          decoration: InputDecoration(
                            hintText: "Search lost item...",

                            prefixIcon: const Icon(Icons.search),

                            fillColor: Colors.white,

                            filled: true,

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),

                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: StreamBuilder<List<ReportModel>>(
                  stream: context.read<ReportProvider>().getReports(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No Reports Found"));
                    }

                    final reports = snapshot.data!;

                    final filteredReports = reports.where((report) {
                      return report.title.toLowerCase().contains(searchText) ||
                          report.location.toLowerCase().contains(searchText) ||
                          report.category.toLowerCase().contains(searchText);
                    }).toList();

                    if (filteredReports.isEmpty) {
                      return const Center(child: Text("No Matching Results"));
                    }

                    return ListView.builder(
                      itemCount: filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = filteredReports[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ItemCard(
                            title: report.title,
                            location: report.location,
                            imageUrl: report.imageUrl.isEmpty
                                ? "https://picsum.photos/200"
                                : report.imageUrl,
                            isLost: report.isLost,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ReportDetailsScreen(report: report),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddReportScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
