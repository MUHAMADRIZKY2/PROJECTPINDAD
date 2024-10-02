import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class AddArticleScreen extends StatefulWidget {
  @override
  _AddArticleScreenState createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  String selectedCategory = 'Kesehatan'; // Default kategori
  final List<String> categories = [
    'Kesehatan',
    'Teknologi',
    'Finansial',
    'Seni',
    'Olahraga'
  ];

  Future<void> requestPermissions() async {
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      var result = await Permission.camera.request();
      if (!result.isGranted) {
        print('Camera permission denied');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera permission denied')),
        );
        return;
      }
    }

    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      var result = await Permission.storage.request();
      if (!result.isGranted) {
        print('Storage permission denied');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }
    }
  }

  void signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      print("Signed in anonymously");
    } catch (e) {
      print("Error signing in: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
    signInAnonymously();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
        await _uploadImage(context, pickedFile.path);
      } else {
        print('No image selected');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected')),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _uploadImage(BuildContext context, String imagePath) async {
    try {
      print('Mengunggah file dari: $imagePath');

      String fileName = 'uploads/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = firebaseStorageRef.putFile(File(imagePath));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploading image...')),
      );

      print('Start uploading image: $fileName');

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {
        print('Upload completed for: $fileName');
      });

      if (taskSnapshot.state == TaskState.success) {
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        print('URL gambar diperoleh: $downloadUrl');

        setState(() {
          imageUrlController.text = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload successful! URL: $downloadUrl')),
        );
      } else {
        print('Upload failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed')),
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    contentController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: authorController,
              decoration: InputDecoration(labelText: 'Author'),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
            ),
            DropdownButton<String>(
              value: selectedCategory,
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
            ),
            TextField(
              controller: imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL'),
              readOnly: true,
            ),
            ElevatedButton(
              onPressed: () => _showPicker(context),
              child: Text('Upload Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty ||
                    authorController.text.trim().isEmpty ||
                    contentController.text.trim().isEmpty ||
                    imageUrlController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                } else {
                  addArticle(
                    titleController.text.trim(),
                    authorController.text.trim(),
                    contentController.text.trim(),
                    imageUrlController.text.trim(),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Add Article'),
            ),
          ],
        ),
      ),
    );
  }

  void addArticle(
      String title, String author, String content, String imageUrl) {
    try {
      FirebaseFirestore.instance.collection('articles').add({
        'title': title,
        'author': author,
        'content': content,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'category': selectedCategory, // Menyimpan kategori yang dipilih
      }).then((value) {
        print('Article Added Successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Article Added Successfully')),
        );
      }).catchError((error) {
        print('Failed to Add Article: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to Add Article: $error')),
        );
      });
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
