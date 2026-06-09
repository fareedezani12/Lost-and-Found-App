import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addReport({
    required String title,
    required String description,
    required String category,
    required String location,
    required bool isLost,
  }) async {
    await firestore.collection("reports").add({
      "title": title,
      "description": description,
      "category": category,
      "location": location,
      "isLost": isLost,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ReportModel>> getReports() {
    return firestore.collection("reports").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> deleteReport(String id) async {
    await firestore.collection("reports").doc(id).delete();
  }

  Future<void> updateStatus({
    required String reportId,
    required String status,
  }) async {
    await firestore.collection("reports").doc(reportId).update({
      "status": status,
    });
  }

  Future<void> claimReport({
    required String reportId,
    required String ownerId,
    required String claimerId,
  }) async {
    final reportDoc = await firestore.collection("reports").doc(reportId).get();

    final userDoc = await firestore.collection("users").doc(claimerId).get();

    final report = reportDoc.data()!;
    final user = userDoc.data()!;

    await firestore.collection("claims").add({
      "reportId": reportId,
      "ownerId": ownerId,
      "claimerId": claimerId,

      "title": report["title"],
      "imageUrl": report["imageUrl"],

      "claimerName": user["fullName"],
      "claimerEmail": user["email"],

      "status": "Pending",
      "createdAt": FieldValue.serverTimestamp(),
    });

    await firestore.collection("reports").doc(reportId).update({
      "status": "Pending",
    });

    await firestore.collection("notifications").add({
      "userId": ownerId,

      "title": "New Claim Request",

      "message":
          "${user["fullName"]} has requested to claim your item '${report["title"]}'.",

      "reportId": reportId,

      "type": "claim",

      "isRead": false,

      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
