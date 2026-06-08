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
    await firestore.collection('reports').add({
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'isLost': isLost,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ReportModel>> getReports() {
    return firestore.collection('reports').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReportModel.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> deleteReport(String id) async {
    await firestore.collection('reports').doc(id).delete();
  }
}
