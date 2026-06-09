import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/cloudinary_service.dart';
import '../home/home_screen.dart';
import '../../widgets/custom_app_bar.dart';

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

  bool isSubmitting = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> saveReport() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields.")),
      );
      return;
    }

    if (imageBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an image.")));
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final imageUrl = await CloudinaryService().uploadImage(imageBytes!);

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception("Image upload failed.");
      }

      await FirebaseFirestore.instance.collection("reports").add({
        "userId": FirebaseAuth.instance.currentUser!.uid,
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "category": category,
        "location": locationController.text.trim(),
        "isLost": reportType == "Lost",
        "imageUrl": imageUrl,
        "status": "Open",
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report saved successfully.")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      imageBytes = await image.readAsBytes();

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(
        title: "Add Report",
        subtitle: "Found Something or Lost Something?",
      ),

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

              onChanged: (value) {
                setState(() {
                  reportType = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: pickImage,

              child: Container(
                height: 180,
                width: double.infinity,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                ),

                child: imageBytes == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Icon(Icons.add_a_photo, size: 55),

                            SizedBox(height: 10),

                            Text("Tap to choose image"),
                          ],
                        ),
                      )
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

              onChanged: (value) {
                setState(() {
                  category = value!;
                });
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
                onPressed: isSubmitting ? null : saveReport,

                child: isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Save Report"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
