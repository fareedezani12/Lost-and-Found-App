import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String location;
  final bool isLost;
  final String imageUrl;
  final String status;
  final Timestamp? createdAt;

  ReportModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.isLost,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
  });

  factory ReportModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ReportModel(
      id: id,
      userId: data["userId"] ?? "",

      title: data["title"] ?? "",

      description: data["description"] ?? "",

      category: data["category"] ?? "",

      location: data["location"] ?? "",

      isLost: data["isLost"] ?? true,

      imageUrl: data["imageUrl"] ?? "",

      status: data["status"] ?? "Open",
      createdAt: data["createdAt"] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "title": title,
      "description": description,
      "category": category,
      "location": location,
      "isLost": isLost,
      "imageUrl": imageUrl,
      "status": status,
      "createdAt": createdAt,
    };
  }
}
