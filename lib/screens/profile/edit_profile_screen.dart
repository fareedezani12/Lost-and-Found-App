import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/cloudinary_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final phoneController = TextEditingController();

  final locationController = TextEditingController();

  Uint8List? imageBytes;

  String photoUrl = "";

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    loadUser();
  }

  Future<void> loadUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    final data = doc.data() as Map<String, dynamic>;

    nameController.text = data["fullName"] ?? "";

    emailController.text = data["email"] ?? "";

    phoneController.text = data["phone"] ?? "";

    locationController.text = data["location"] ?? "";

    photoUrl = data["photoUrl"] ?? "";

    setState(() {});
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      imageBytes = await image.readAsBytes();

      setState(() {});
    }
  }

  Future<void> saveProfile() async {
    setState(() {
      isLoading = true;
    });

    String finalPhoto = photoUrl;

    if (imageBytes != null) {
      final uploaded = await CloudinaryService().uploadImage(imageBytes!);

      if (uploaded != null) {
        finalPhoto = uploaded;
      }
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
          "fullName": nameController.text.trim(),

          "phone": phoneController.text.trim(),

          "location": locationController.text.trim(),

          "photoUrl": finalPhoto,
        });

    setState(() {
      isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile Updated")));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,

              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,

                    backgroundImage: imageBytes != null
                        ? MemoryImage(imageBytes!)
                        : photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null as ImageProvider?,

                    child: imageBytes == null && photoUrl.isEmpty
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),

                  Positioned(
                    bottom: 0,

                    right: 0,

                    child: CircleAvatar(
                      backgroundColor: Colors.blue,

                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: nameController,

              decoration: const InputDecoration(
                labelText: "Full Name",

                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              readOnly: true,

              controller: emailController,

              decoration: const InputDecoration(
                labelText: "Email",

                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,

              keyboardType: TextInputType.phone,

              decoration: const InputDecoration(
                labelText: "Phone",

                prefixIcon: Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: locationController,

              decoration: const InputDecoration(
                labelText: "Location",

                prefixIcon: Icon(Icons.location_on),
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,

              height: 55,

              child: ElevatedButton(
                onPressed: isLoading ? null : saveProfile,

                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
