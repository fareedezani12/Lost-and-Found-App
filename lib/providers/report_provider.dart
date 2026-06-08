import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();

  bool isLoading = false;

  Future<void> addReport({
    required String title,
    required String description,
    required String category,
    required String location,
    required bool isLost,
  }) async {
    isLoading = true;
    notifyListeners();

    await _reportService.addReport(
      title: title,
      description: description,
      category: category,
      location: location,
      isLost: isLost,
    );

    isLoading = false;
    notifyListeners();
  }

  Stream<List<ReportModel>> getReports() {
    return _reportService.getReports();
  }

  Future<void> deleteReport(String id) async {
    await _reportService.deleteReport(id);
    notifyListeners();
  }

  Future<void> claimReport({
    required String reportId,
    required String ownerId,
    required String claimerId,
  }) async {
    await _reportService.claimReport(
      reportId: reportId,
      ownerId: ownerId,
      claimerId: claimerId,
    );

    notifyListeners();
  }

  Future<void> updateStatus({
    required String reportId,
    required String status,
  }) async {
    await _reportService.updateStatus(reportId: reportId, status: status);

    notifyListeners();
  }
}
