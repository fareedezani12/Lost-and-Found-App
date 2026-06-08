import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edit_report_screen.dart';
import '../../models/report_model.dart';
import '../../providers/report_provider.dart';

class ReportDetailsScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailsScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Details")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              report.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text(report.description),

            const SizedBox(height: 20),

            Text("Category: ${report.category}"),

            const SizedBox(height: 10),

            Text("Location: ${report.location}"),

            const SizedBox(height: 10),

            Text(report.isLost ? "Status: Lost" : "Status: Found"),

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

            const Spacer(),

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
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Delete Report"),

                        content: const Text("Are you sure?"),

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
