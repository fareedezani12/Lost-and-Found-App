import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
              mainAxisAlignment: MainAxisAlignment.center,
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

  Widget lostFoundChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("reports").snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        int lost = 0;
        int found = 0;

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;

          if (data["isLost"] == true) {
            lost++;
          } else {
            found++;
          }
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  "Lost vs Found Reports",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                      sections: [
                        PieChartSectionData(
                          value: lost.toDouble(),
                          title: "Lost\n$lost",
                          radius: 70,
                        ),

                        PieChartSectionData(
                          value: found.toDouble(),
                          title: "Found\n$found",
                          radius: 70,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget claimStatusChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("claims").snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        int approved = 0;
        int pending = 0;
        int rejected = 0;

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;

          switch (data["status"]) {
            case "Approved":
              approved++;
              break;

            case "Rejected":
              rejected++;
              break;

            default:
              pending++;
          }
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [
                const Text(
                  "Claim Status",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 250,

                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 50,
                      sectionsSpace: 3,

                      sections: [
                        PieChartSectionData(
                          value: approved.toDouble(),
                          title: "Approved\n$approved",
                          color: Colors.green,
                          radius: 70,
                        ),

                        PieChartSectionData(
                          value: pending.toDouble(),
                          title: "Pending\n$pending",
                          color: Colors.orange,
                          radius: 70,
                        ),

                        PieChartSectionData(
                          value: rejected.toDouble(),
                          title: "Rejected\n$rejected",
                          color: Colors.red,
                          radius: 70,
                        ),
                      ],
                    ),
                  ),
                ),
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
      appBar: AppBar(title: const Text("System Analytics")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,

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

            const SizedBox(height: 20),

            lostFoundChart(),

            const SizedBox(height: 20),

            claimStatusChart(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
