import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/home_screen.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
/*import 'package:firebase_storage/firebase_storage.dart';*/

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();

  String reportType = "Lost";
  String category = "Electronics";
  Uint8List? imageBytes;

  bool isSubmitting = false; // <-- Correct place for the flag

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Report")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField(
              initialValue: reportType,
              items: const [
                DropdownMenuItem(value: "Lost", child: Text("Lost Item")),
                DropdownMenuItem(value: "Found", child: Text("Found Item")),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => reportType = value);
                }
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();

                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                );

                if (image != null) {
                  imageBytes = await image.readAsBytes();

                  setState(() {});
                }
              },

              child: Container(
                height: 150,
                width: double.infinity,

                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(15),
                ),

                child: imageBytes == null
                    ? const Center(child: Icon(Icons.image, size: 60))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),

                        child: Image.memory(imageBytes!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 20),
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
            DropdownButtonFormField(
              initialValue: category,
              items: const [
                DropdownMenuItem(
                  value: "Electronics",
                  child: Text("Electronics"),
                ),
                DropdownMenuItem(value: "Documents", child: Text("Documents")),
                DropdownMenuItem(
                  value: "Accessories",
                  child: Text("Accessories"),
                ),
              ],
              onChanged: (String? value) {
                if (value != null) setState(() => category = value);
              },
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
                  try {
                    /*String imageUrl = "";

                    if (imageBytes != null) {
                      final ref = FirebaseStorage.instance.ref().child(
                        "reports/${DateTime.now().millisecondsSinceEpoch}.jpg",
                      );

                      await ref.putData(imageBytes!);

                      imageUrl = await ref.getDownloadURL();
                    }*/

                    await FirebaseFirestore.instance.collection('reports').add({
                      'title': titleController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'category': category,
                      'location': locationController.text.trim(),
                      'isLost': reportType == "Lost",
                      'imageUrl': 'https://picsum.photos/300',
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Report Saved Successfully"),
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    }
                  } catch (e) {
                    print("ERROR: $e");

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("ERROR: $e")));
                  }
                },
                child: const Text("Save Report"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
