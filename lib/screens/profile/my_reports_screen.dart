import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../report/report_details_screen.dart';
import '../../models/report_model.dart';
import '../../widgets/custom_app_bar.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: const CustomHeader(
        title: "My Report",
        subtitle: "List of Your Reports",
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("reports")
            .where("userId", isEqualTo: uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("You haven't posted any reports."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,

            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final report = ReportModel.fromFirestore(docs[index].id, data);

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(report.title.isEmpty ? "?" : report.title[0]),
                  ),

                  title: Text(report.title),

                  subtitle: Text(report.location),

                  trailing: const Icon(Icons.arrow_forward_ios),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportDetailsScreen(report: report),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
