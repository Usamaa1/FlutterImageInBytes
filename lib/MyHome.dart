import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  TextEditingController username = TextEditingController();
  TextEditingController city = TextEditingController();

  File? _pickedFile;
  Uint8List? _imageBytes;

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final image = File(pickedFile.path);

      Uint8List imageBytes = await image.readAsBytes();

      setState(() {
        _pickedFile = image;
        _imageBytes = imageBytes;
      });
      print("Image in Binay: $_imageBytes");
    }
  }

  Future<void> addUser() async {
    try {
      final user = await FirebaseFirestore.instance.collection("users").add({
        "city": city.text,
        "username": username.text,
        "image": "$_imageBytes", // Store image in binary format in Firestore
      });
      print("User added with ID: ${user.id}");
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imageBytes != null
                  ? Image.memory(_imageBytes!) // Display image from binary data
                  : const Text("No image selected"),
              TextField(
                controller: username,
                decoration: const InputDecoration(
                  labelText: 'Enter your username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: city,
                decoration: const InputDecoration(
                  labelText: 'Enter your city',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  onPressed: pickImage,
                  label: const Text("Upload Image")),
              ElevatedButton(onPressed: addUser, child: const Text("Add"))
            ],
          ),
        ),
      ),
    );
  }
}
