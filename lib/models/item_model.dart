class ItemModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String imageUrl;
  final bool isLost;

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.isLost,
  });
}
