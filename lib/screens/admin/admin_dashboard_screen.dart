import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'manage_users_screen.dart';
import 'manage_reports_screen.dart';
import 'manage_claims_screen.dart';
import 'analytics_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Widget buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required Stream<QuerySnapshot> stream,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,

      builder: (context, snapshot) {
        final total = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(22),

            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.15),

                blurRadius: 10,

                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.all(18),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Align(
                  alignment: Alignment.topRight,

                  child: CircleAvatar(
                    radius: 22,

                    backgroundColor: color.withValues(alpha: 0.15),

                    child: Icon(icon, color: color),
                  ),
                ),

                const Spacer(),

                Text(
                  total.toString(),

                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  title,

                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget actionTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),

        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),

          child: Icon(icon, color: color),
        ),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

        trailing: const Icon(Icons.chevron_right),

        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }

  /*Widget recentActivities() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("reports")
          .orderBy("createdAt", descending: true)
          .limit(5)
          .snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data!.docs;

        return Card(
          elevation: 2,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          child: ListView.separated(
            shrinkWrap: true,

            physics: const NeverScrollableScrollPhysics(),

            itemCount: reports.length,

            separatorBuilder: (_, __) => const Divider(height: 1),

            itemBuilder: (context, index) {
              final data = reports[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: data["isLost"] == true
                      ? Colors.red.shade100
                      : Colors.green.shade100,

                  child: Icon(
                    data["isLost"] == true
                        ? Icons.search_off
                        : Icons.check_circle,

                    color: data["isLost"] == true ? Colors.red : Colors.green,
                  ),
                ),

                title: Text(data["title"] ?? ""),

                subtitle: Text(
                  data["isLost"] == true
                      ? "New Lost Report"
                      : "New Found Report",
                ),

                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              );
            },
          ),
        );
      },
    );
  }*/

  Widget recentTimeline() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("reports")
          .orderBy("createdAt", descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recent Timeline",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reports.length,

              itemBuilder: (context, index) {
                final data = reports[index].data() as Map<String, dynamic>;

                final isLost = data["isLost"] == true;

                Timestamp? timestamp = data["createdAt"];

                String timeText = "";

                if (timestamp != null) {
                  final date = timestamp.toDate();

                  final diff = DateTime.now().difference(date);

                  if (diff.inMinutes < 60) {
                    timeText = "${diff.inMinutes} min ago";
                  } else if (diff.inHours < 24) {
                    timeText = "${diff.inHours} hours ago";
                  } else if (diff.inDays == 1) {
                    timeText = "Yesterday";
                  } else {
                    timeText = "${diff.inDays} days ago";
                  }
                }

                return IntrinsicHeight(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 9,

                            backgroundColor: isLost ? Colors.red : Colors.green,
                          ),

                          Container(width: 2, color: Colors.grey.shade300),
                        ],
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Card(
                          elevation: 2,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(15),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  timeText,

                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  isLost
                                      ? "Lost Report Created"
                                      : "Found Report Created",

                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(data["title"] ?? ""),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.circular(25),

                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Image.asset(
                      "assets/images/lost-and-found-app-logo.png",
                      width: 45,
                      height: 45,
                    ),
                  ),

                  const SizedBox(width: 18),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "Lost & Found",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "Management System",
                          style: TextStyle(color: Colors.white70, fontSize: 17),
                        ),

                        SizedBox(height: 10),

                        Text(
                          "Administrator Panel",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),

                        child: IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),

                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Logout"),
                                content: const Text(
                                  "Are you sure you want to logout?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),

                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Logout"),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await FirebaseAuth.instance.signOut();

                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            GridView.count(
              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: 2,

              childAspectRatio: 1.15,

              crossAxisSpacing: 15,

              mainAxisSpacing: 15,

              children: [
                buildCard(
                  title: "Users",

                  icon: Icons.people,

                  color: Colors.blue,

                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .snapshots(),
                ),

                buildCard(
                  title: "Reports",

                  icon: Icons.inventory,

                  color: Colors.green,

                  stream: FirebaseFirestore.instance
                      .collection("reports")
                      .snapshots(),
                ),

                buildCard(
                  title: "Claims",

                  icon: Icons.assignment,

                  color: Colors.orange,

                  stream: FirebaseFirestore.instance
                      .collection("claims")
                      .snapshots(),
                ),

                buildCard(
                  title: "Notifications",

                  icon: Icons.notifications,

                  color: Colors.red,

                  stream: FirebaseFirestore.instance
                      .collection("notifications")
                      .snapshots(),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Quick Actions",

              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            actionTile(
              context: context,
              title: "Manage Users",
              icon: Icons.people,
              color: Colors.blue,
              page: const ManageUsersScreen(),
            ),

            const SizedBox(height: 12),

            actionTile(
              context: context,
              title: "Manage Reports",
              icon: Icons.inventory_2,
              color: Colors.green,
              page: const ManageReportsScreen(),
            ),

            const SizedBox(height: 12),

            actionTile(
              context: context,
              title: "Manage Claims",
              icon: Icons.assignment,
              color: Colors.orange,
              page: const ManageClaimsScreen(),
            ),

            const SizedBox(height: 12),

            actionTile(
              context: context,
              title: "Analytics",
              icon: Icons.bar_chart_rounded,
              color: Colors.purple,
              page: const AnalyticsScreen(),
            ),

            const SizedBox(height: 30),

            recentTimeline(),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xff1565C0).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Color(0xff1565C0),
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Administrator Access",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "You have full control over users, reports and claims.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
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
                    ),
                  );

                  if (confirm == true) {
                    await FirebaseAuth.instance.signOut();

                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  }
                },
              ),
            ),

            /*const Text(
              "Recent Activities",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            recentActivities(),*/
          ],
        ),
      ),
    );
  }
}
