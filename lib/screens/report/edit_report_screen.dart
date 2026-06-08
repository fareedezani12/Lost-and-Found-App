import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/report_model.dart';

class EditReportScreen extends StatefulWidget {
  final ReportModel report;

  const EditReportScreen({super.key, required this.report});

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.report.title);

    descriptionController = TextEditingController(
      text: widget.report.description,
    );

    locationController = TextEditingController(text: widget.report.location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Report")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Location"),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('reports')
                      .doc(widget.report.id)
                      .update({
                        'title': titleController.text,

                        'description': descriptionController.text,

                        'location': locationController.text,
                      });

                  if (mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("Updated")));
                  }
                },

                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
