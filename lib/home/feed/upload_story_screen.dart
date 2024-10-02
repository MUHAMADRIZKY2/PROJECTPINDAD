import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambahkan ini untuk mendapatkan currentUser
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadStoryScreen extends StatefulWidget {
  @override
  _UploadStoryScreenState createState() => _UploadStoryScreenState();
}

class _UploadStoryScreenState extends State<UploadStoryScreen> {
  final _picker = ImagePicker();
  XFile? _image;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  bool _isUploading = false; // Untuk menampilkan status pengunggahan
  String _errorMessage = ''; // Untuk menampilkan pesan error

  Future<void> _uploadStory() async {
    if (_image == null) {
      setState(() {
        _errorMessage = 'Please select an image.';
      });
      return;
    }

    try {
      setState(() {
        _isUploading = true; // Menampilkan indikator pengunggahan
        _errorMessage = ''; // Reset pesan error
      });

      // Upload image to Firebase Storage
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = _storage.ref().child('stories/$fileName');
      await storageRef.putFile(File(_image!.path));
      final imageUrl = await storageRef.getDownloadURL();

      // Dapatkan current user ID
      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserId = currentUser?.uid;

      if (currentUserId == null) {
        setState(() {
          _errorMessage = 'User not logged in.';
        });
        return;
      }

      // Save story to Firestore
      await _firestore.collection('stories').add({
        'userId': currentUserId,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update atau buat dokumen user
      await _firestore.collection('users').doc(currentUserId).set({
        'hasUploadedStory': true,
      }, SetOptions(merge: true)); // Merge untuk tidak overwrite data lain

      // Navigasi kembali setelah pengunggahan selesai
      Navigator.of(context).pop();
    } catch (e) {
      // Tangkap kesalahan selama proses upload
      setState(() {
        _errorMessage = 'Failed to upload story: $e';
      });
    } finally {
      setState(() {
        _isUploading = false; // Reset status pengunggahan
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = pickedFile;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Story'),
      ),
      body: Column(
        children: [
          _image == null
              ? Text('No image selected.')
              : Image.file(File(_image!.path)),
          if (_isUploading)
            CircularProgressIndicator(), // Menampilkan loading jika upload sedang berjalan
          if (_errorMessage.isNotEmpty)
            Text(_errorMessage,
                style: TextStyle(color: Colors.red)), // Menampilkan pesan error
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Pick Image'),
          ),
          ElevatedButton(
            onPressed: _isUploading
                ? null
                : _uploadStory, // Nonaktifkan tombol saat pengunggahan sedang berlangsung
            child: Text('Upload Story'),
          ),
        ],
      ),
    );
  }
}
