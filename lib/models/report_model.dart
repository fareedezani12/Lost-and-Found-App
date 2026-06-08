class ReportModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final bool isLost;
  final String imageUrl;

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.isLost,
    required this.imageUrl,
  });

  factory ReportModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ReportModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      isLost: data['isLost'] ?? true,
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
