import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
import 'package:image_picker/image_picker.dart'; // Untuk memilih gambar
import 'dart:io'; // Untuk file handling
import 'package:firebase_storage/firebase_storage.dart'; // Untuk Firebase Storage
import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk Firebase Firestore

class ProfileDetailScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String email;
  final String? profileImageUrl;

  ProfileDetailScreen({
    required this.userId,
    required this.username,
    required this.email,
    this.profileImageUrl,
  });

  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  // Data profil yang bisa diedit
  String name = '';
  String studentId = '';
  String gender = 'Laki-laki'; // Default gender value
  String address = '';
  String city = '';
  String phone = '';
  String tahunLulus = '';
  String department = '';
  String occupation = '';
  String hometown = '';
  String maritalStatus = '';
  String siblings = '';
  String notes = '';
  String lastClass = '';
  String jumlahAnak = ''; // Jumlah anak
  String kondisiSaatIni = '';
  String harapan = '';
  String kandidatKetua = ''; // Input kandidat ketua

  String? _profileImageUrl; // URL untuk gambar profil

  // Firebase Firestore instance
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    _profileImageUrl = widget.profileImageUrl;
    name = widget.username; // Mengambil nama pengguna dari ProfileScreen
    _loadProfileData(); // Memuat data profil tambahan dari Firestore
  }

  // Fungsi untuk memuat data dari Firestore
  Future<void> _loadProfileData() async {
    try {
      DocumentSnapshot userDoc = await usersCollection.doc(widget.userId).get();

      if (userDoc.exists) {
        setState(() {
          studentId = userDoc['studentId'] ?? '';
          gender = userDoc['gender'] ?? 'Laki-laki';
          address = userDoc['address'] ?? '';
          city = userDoc['city'] ?? '';
          phone = userDoc['phone'] ?? '';
          tahunLulus = userDoc['tahunLulus'] ?? '';
          department = userDoc['department'] ?? '';
          occupation = userDoc['occupation'] ?? '';
          hometown = userDoc['hometown'] ?? '';
          maritalStatus = userDoc['maritalStatus'] ?? '';
          siblings = userDoc['siblings'] ?? '';
          notes = userDoc['notes'] ?? '';
          lastClass = userDoc['lastClass'] ?? '';
          kondisiSaatIni = userDoc['kondisiSaatIni'] ?? '';
          harapan = userDoc['harapan'] ?? '';
          kandidatKetua = userDoc['kandidatKetua'] ?? '';
          jumlahAnak = userDoc['jumlahAnak'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading profile data from Firestore: $e');
    }
  }

  // Fungsi untuk menyimpan biodata ke Firestore
  Future<void> _saveUserData() async {
    try {
      await usersCollection.doc(widget.userId).set({
        'name': name,
        'studentId': studentId,
        'gender': gender,
        'address': address,
        'city': city,
        'phone': phone,
        'tahunLulus': tahunLulus,
        'department': department,
        'occupation': occupation,
        'hometown': hometown,
        'maritalStatus': maritalStatus,
        'siblings': siblings,
        'notes': notes,
        'lastClass': lastClass,
        'kondisiSaatIni': kondisiSaatIni,
        'harapan': harapan,
        'kandidatKetua': kandidatKetua,
        'jumlahAnak': jumlahAnak,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biodata berhasil disimpan!')),
      );
    } catch (e) {
      print('Error saving user data to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan biodata. Coba lagi.')),
      );
    }
  }

  // Fungsi untuk menampilkan header profil dengan foto dan nama
  Widget _buildProfileHeader() {
    return Stack(
      children: [
        // Warna gradasi di bawah
        ClipPath(
          clipper: CustomCurveClipper(),
          child: Container(
            padding: const EdgeInsets.all(30.0),
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 10, 90, 156),
                  Color.fromARGB(255, 10, 90, 156)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25.0),
            ),
            height: 140,
          ),
        ),
        // Gradasi putih ke ungu di atas
        ClipPath(
          clipper: CustomCurveClipper2(),
          child: Container(
            padding: const EdgeInsets.all(30.0),
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.white,
                  Color.fromARGB(255, 106, 62, 182)
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25.0),
            ),
            height: 140,
          ),
        ),
        // Konten profil di atas kedua layer
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.all(30.0),
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            height: 140,
            child: Row(
              children: [
                // Avatar pengguna yang dapat diubah saat diklik
                GestureDetector(
                  onTap: _showProfileDialog, // Panggil fungsi dialog saat foto ditekan
                  child: CircleAvatar(
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!) // Tampilkan gambar dari URL
                        : AssetImage('lib/assets/images/user1.png') as ImageProvider,
                    radius: 40,
                  ),
                ),
                const SizedBox(width: 30), // Menggeser username lebih ke kanan
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nama pengguna dan email
                    Text(
                      widget.username.isNotEmpty ? widget.username : 'User', // Menampilkan nama pengguna
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.email.isNotEmpty ? widget.email : 'Email tidak tersedia', // Menampilkan email
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Fungsi untuk menampilkan dialog gambar profil dengan opsi untuk mengganti foto
  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gambar profil besar
              Container(
                margin: const EdgeInsets.all(20),
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!) // Gambar dari URL
                        : AssetImage('lib/assets/images/user1.png') as ImageProvider, // Gambar default
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Tombol ubah foto
              TextButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text("Ubah Foto"),
                onPressed: () {
                  _pickImage(); // Memilih gambar dari galeri
                  Navigator.of(context).pop(); // Menutup dialog setelah gambar dipilih
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      await _uploadImageToFirebase(file); // Unggah gambar ke Firebase
    }
  }

  // Fungsi untuk mengunggah gambar ke Firebase Storage dan menyimpan URL di Firestore
  Future<void> _uploadImageToFirebase(File file) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${widget.userId}.jpg');
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      setState(() {
        _profileImageUrl = downloadUrl;
      });

      // Simpan URL gambar ke Firestore berdasarkan userId
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'profileImage': downloadUrl,
      });
    } catch (e) {
      print('Error uploading image to Firebase: $e');
    }
  }

  // Widget untuk membuat form field yang dapat diedit atau label jika tidak dapat diubah
  Widget _buildProfileField(String label, String initialValue, String key, {bool isReadOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: isReadOnly ? null : (value) {
          _saveDataOnChange(key, value);
        },
        readOnly: isReadOnly, // Menjadikan field read-only jika isReadOnly bernilai true
        validator: isReadOnly ? null : (value) {
          if (value == null || value.isEmpty) {
            return 'Mohon isi $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Detail'),
        backgroundColor: const Color.fromRGBO(15, 128, 221, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(), // Menambahkan header profil dengan foto dan nama
                _buildProfileField('Nama', name, 'name'),
                _buildProfileField('NIM', studentId, 'studentId'),
                _buildProfileField('Email', widget.email, 'email', isReadOnly: true), // Membuat email tidak dapat diubah
                _buildProfileField('Alamat', address, 'address'),
                _buildProfileField('Kota', city, 'city'),
                _buildProfileField('Telepon', phone, 'phone'),
                _buildProfileField('Tahun Lulus', tahunLulus, 'tahunLulus'),
                _buildProfileField('Jurusan', department, 'department'),
                _buildProfileField('Pekerjaan', occupation, 'occupation'),
                _buildProfileField('Kota Asal', hometown, 'hometown'),
                _buildProfileField('Status Pernikahan', maritalStatus, 'maritalStatus'),
                _buildProfileField('Jumlah Saudara', siblings, 'siblings'),
                _buildProfileField('Catatan', notes, 'notes'),
                _buildProfileField('Asal Kelas Terakhir', lastClass, 'lastClass'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveUserData(); // Simpan data ke Firestore
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menyimpan perubahan data profil
  void _saveDataOnChange(String key, String value) {
    setState(() {
      switch (key) {
        case 'name':
          name = value;
          break;
        case 'studentId':
          studentId = value;
          break;
        case 'address':
          address = value;
          break;
        case 'city':
          city = value;
          break;
        case 'phone':
          phone = value;
          break;
        case 'tahunLulus':
          tahunLulus = value;
          break;
        case 'department':
          department = value;
          break;
        case 'occupation':
          occupation = value;
          break;
        case 'hometown':
          hometown = value;
          break;
        case 'maritalStatus':
          maritalStatus = value;
          break;
        case 'siblings':
          siblings = value;
          break;
        case 'notes':
          notes = value;
          break;
        case 'lastClass':
          lastClass = value;
          break;
      }
    });
  }
}

// Custom clippers untuk efek gradasi pada header
class CustomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width - 70, 0);
    path.quadraticBezierTo(size.width, size.height / 1, size.width - 150, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class CustomCurveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width - 70, 0);
    path.quadraticBezierTo(size.width, size.height / 1, size.width - 150, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
