import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_users_screen.dart';
import 'manage_reports_screen.dart';
import 'manage_claims_screen.dart';
import 'analytics_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Widget buildCard(
    String title,
    IconData icon,
    Color color,
    Stream<QuerySnapshot> stream,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final total = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Icon(icon, size: 40, color: color),

                const SizedBox(height: 10),

                Text(
                  total.toString(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(title),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              children: [
                buildCard(
                  "Users",
                  Icons.people,
                  Colors.blue,
                  FirebaseFirestore.instance.collection("users").snapshots(),
                ),

                buildCard(
                  "Reports",
                  Icons.description,
                  Colors.green,
                  FirebaseFirestore.instance.collection("reports").snapshots(),
                ),

                buildCard(
                  "Claims",
                  Icons.assignment,
                  Colors.orange,
                  FirebaseFirestore.instance.collection("claims").snapshots(),
                ),

                buildCard(
                  "Notifications",
                  Icons.notifications,
                  Colors.red,
                  FirebaseFirestore.instance
                      .collection("notifications")
                      .snapshots(),
                ),
              ],
            ),

            const SizedBox(height: 30),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Manage Users"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text("Manage Reports"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageReportsScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text("Manage Claims"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageClaimsScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.bar_chart),

              title: const Text("Analytics"),

              trailing: const Icon(Icons.arrow_forward_ios),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
