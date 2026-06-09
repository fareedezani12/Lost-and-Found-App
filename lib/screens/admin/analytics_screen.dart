import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/custom_app_bar.dart';

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
      appBar: const CustomHeader(
        title: "Analytics",
        subtitle: "System statistics and charts",
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            lostFoundBarChart(),

            const SizedBox(height: 20),

            claimStatusChart(),

            const SizedBox(height: 20),

            categoryChart(),

            const SizedBox(height: 20),

            monthlyReportChart(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

Widget buildLegend(Color color, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      const SizedBox(width: 8),

      Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    ],
  );
}

Widget lostFoundBarChart() {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Lost vs Found Reports",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 280,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,

                    borderData: FlBorderData(show: false),

                    gridData: FlGridData(show: false),

                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) {
                              return const Text("Lost");
                            }
                            return const Text("Found");
                          },
                        ),
                      ),
                    ),

                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: lost.toDouble(),
                            color: Colors.red,
                            width: 40,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),

                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: found.toDouble(),
                            color: Colors.green,
                            width: 40,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Claim Status",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 280,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 70,
                    sectionsSpace: 4,

                    sections: [
                      PieChartSectionData(
                        value: approved.toDouble(),
                        title: "$approved",
                        color: Colors.green,
                        radius: 90,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      PieChartSectionData(
                        value: pending.toDouble(),
                        title: "$pending",
                        color: Colors.orange,
                        radius: 90,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      PieChartSectionData(
                        value: rejected.toDouble(),
                        title: "$rejected",
                        color: Colors.red,
                        radius: 90,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(radius: 6, backgroundColor: Colors.green),
                      SizedBox(width: 5),
                      Text("Approved"),
                    ],
                  ),

                  Row(
                    children: const [
                      CircleAvatar(radius: 6, backgroundColor: Colors.orange),
                      SizedBox(width: 5),
                      Text("Pending"),
                    ],
                  ),

                  Row(
                    children: const [
                      CircleAvatar(radius: 6, backgroundColor: Colors.red),
                      SizedBox(width: 5),
                      Text("Rejected"),
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
}

Widget categoryChart() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection("reports").snapshots(),

    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      int electronics = 0;
      int documents = 0;
      int accessories = 0;

      for (var doc in snapshot.data!.docs) {
        final data = doc.data() as Map<String, dynamic>;

        switch (data["category"]) {
          case "Electronics":
            electronics++;
            break;

          case "Documents":
            documents++;
            break;

          case "Accessories":
            accessories++;
            break;
        }
      }

      return Card(
        elevation: 3,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                "Reports by Category",

                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 300,

                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),

                    gridData: FlGridData(show: true),

                    alignment: BarChartAlignment.spaceAround,

                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,

                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text("Electronics");

                              case 1:
                                return const Text("Documents");

                              case 2:
                                return const Text("Accessories");
                            }

                            return const SizedBox();
                          },
                        ),
                      ),
                    ),

                    barGroups: [
                      BarChartGroupData(
                        x: 0,

                        barRods: [
                          BarChartRodData(
                            toY: electronics.toDouble(),

                            width: 35,

                            color: Colors.blue,

                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),

                      BarChartGroupData(
                        x: 1,

                        barRods: [
                          BarChartRodData(
                            toY: documents.toDouble(),

                            width: 35,

                            color: Colors.orange,

                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),

                      BarChartGroupData(
                        x: 2,

                        barRods: [
                          BarChartRodData(
                            toY: accessories.toDouble(),

                            width: 35,

                            color: Colors.green,

                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
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

Widget monthlyReportChart() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection("reports").snapshots(),

    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      List<int> monthData = List.generate(12, (index) => 0);

      for (var doc in snapshot.data!.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (data["createdAt"] != null) {
          final date = (data["createdAt"] as Timestamp).toDate();

          monthData[date.month - 1]++;
        }
      }

      return Card(
        elevation: 3,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                "Monthly Reports",

                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 300,

                child: LineChart(
                  LineChartData(
                    borderData: FlBorderData(show: false),

                    gridData: FlGridData(show: true),

                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          12,

                          (i) => FlSpot(i.toDouble(), monthData[i].toDouble()),
                        ),

                        isCurved: true,

                        color: const Color(0xff1565C0),

                        barWidth: 4,

                        dotData: FlDotData(show: true),

                        belowBarData: BarAreaData(
                          show: true,

                          color: const Color(
                            0xff1565C0,
                          ).withValues(alpha: 0.15),
                        ),
                      ),
                    ],

                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,

                          getTitlesWidget: (value, meta) {
                            const months = [
                              "Jan",

                              "Feb",

                              "Mar",

                              "Apr",

                              "May",

                              "Jun",

                              "Jul",

                              "Aug",

                              "Sep",

                              "Oct",

                              "Nov",

                              "Dec",
                            ];

                            if (value.toInt() >= 0 && value.toInt() < 12) {
                              return Text(months[value.toInt()]);
                            }

                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
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
