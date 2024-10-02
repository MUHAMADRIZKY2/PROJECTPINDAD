import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoUploadScreen extends StatefulWidget {
  @override
  _PhotoUploadScreenState createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _image;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPhoto() async {
    if (_image == null ||
        _captionController.text.isEmpty ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Foto, caption, dan lokasi harus diisi!")));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload foto ke Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child("feed").child(fileName);
      UploadTask uploadTask = storageReference.putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      String photoUrl = await taskSnapshot.ref.getDownloadURL();

      // Ambil informasi pengguna yang sedang login
      final User? user = FirebaseAuth.instance.currentUser;
      String userName = user?.displayName ?? 'Anonymous';  // Ambil nama pengguna, jika ada

      // Simpan data ke Firestore
      await FirebaseFirestore.instance.collection('feed').add({
        'photoUrl': photoUrl,
        'caption': _captionController.text,
        'timestamp': Timestamp.now(),
        'userId': user?.uid,
        'userName': userName,  // Tambahkan nama pengguna yang sedang login
        'location': _locationController.text,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Foto berhasil diunggah!")));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal mengunggah foto: $e")));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unggah Foto"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _image == null
                ? Text("Pilih foto untuk diunggah.")
                : Image.file(_image!, height: 250),
            TextField(
              controller: _captionController,
              decoration: InputDecoration(labelText: "Caption"),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: "Lokasi"),
            ),
            SizedBox(height: 20),
            _isUploading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadPhoto,
                    child: Text("Unggah"),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
