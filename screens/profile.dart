import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final File? currentImage;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentEmail,
    this.currentImage,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
    _selectedImage = widget.currentImage;
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Adds padding for better UI
        child: Column(
          children: [
            // Profile Picture Section
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 80, // Bigger Profile Image
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : const AssetImage("assets/profile.jpg") as ImageProvider,
                child: const Icon(Icons.camera_alt, size: 30, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Full-Screen Form Fields
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),

            // Save Button
            SizedBox(
              width: double.infinity, // Full-width button
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15), // Bigger button
                  backgroundColor: Colors.blue,
                ),
                onPressed: () async{
                  User? user=FirebaseAuth.instance.currentUser;
                  String userId=user?.uid??"";
                  await FirebaseFirestore.instance.collection("User").doc(userId).update({"name":_nameController.text});
                  Navigator.pop(context, {
                    "name": _nameController.text,
                    "email": _emailController.text,
                    "image": _selectedImage,
                  });
                },
                child: const Text("Save", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}