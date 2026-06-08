import '../../models/item_model.dart';

final List<ItemModel> dummyItems = [
  ItemModel(
    id: "1",
    title: "Black Backpack",
    description: "Lost near UPSI Library",
    category: "Accessories",
    location: "Library",
    imageUrl: "https://picsum.photos/300",
    isLost: true,
  ),

  ItemModel(
    id: "2",
    title: "AirPods Pro",
    description: "Found near Cafe",
    category: "Electronics",
    location: "Cafe",
    imageUrl: "https://picsum.photos/301",
    isLost: false,
  ),

  ItemModel(
    id: "3",
    title: "Student Card",
    description: "Found in Block A",
    category: "Documents",
    location: "Block A",
    imageUrl: "https://picsum.photos/302",
    isLost: false,
  ),
];
