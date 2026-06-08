import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/report_model.dart';
import '../../providers/report_provider.dart';
import 'edit_report_screen.dart';

class ReportDetailsScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailsScreen({super.key, required this.report});

  Color getStatusColor() {
    switch (report.status) {
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
    final currentUser = FirebaseAuth.instance.currentUser;

    final bool isOwner =
        currentUser != null && currentUser.uid == report.userId;
    return Scaffold(
      appBar: AppBar(title: const Text("Report Details")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              height: 220,
              width: double.infinity,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),

                child: Image.network(
                  report.imageUrl.isEmpty
                      ? "https://picsum.photos/500"
                      : report.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color: getStatusColor(),
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Text(
                    report.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 8),

            Text(report.description),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.category),
                title: const Text("Category"),
                subtitle: Text(report.category),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text("Location"),
                subtitle: Text(report.location),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: Icon(
                  report.isLost ? Icons.search_off : Icons.check_circle,
                ),
                title: const Text("Type"),
                subtitle: Text(report.isLost ? "Lost Item" : "Found Item"),
              ),
            ),

            const SizedBox(height: 25),

            if (!isOwner && report.status == "Open") ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.handshake),
                  label: const Text("Claim Item"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final currentUser = FirebaseAuth.instance.currentUser!;

                    await context.read<ReportProvider>().claimReport(
                      reportId: report.id,
                      ownerId: report.userId,
                      claimerId: currentUser.uid,
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Claim request sent")),
                      );

                      Navigator.pop(context);
                    }
                  },
                ),
              ),

              const SizedBox(height: 15),
            ],

            if (isOwner)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Report"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditReportScreen(report: report),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 15),

            if (isOwner)
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete),

                  label: const Text("Delete Report"),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),

                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,

                      builder: (_) {
                        return AlertDialog(
                          title: const Text("Delete"),

                          content: const Text("Delete this report?"),

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
                      await context.read<ReportProvider>().deleteReport(
                        report.id,
                      );

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
      ),
    );
  }
}
