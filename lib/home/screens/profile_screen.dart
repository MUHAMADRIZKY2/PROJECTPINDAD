import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_application_1/home/screens/profile_detail_screen.dart';
import 'package:flutter_application_1/login_screen.dart';
import 'package:flutter_application_1/home/widgets/profile_menu_item.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import untuk SharedPreferences
import 'package:firebase_auth/firebase_auth.dart'; // Import untuk Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import untuk Firestore
import 'package:firebase_storage/firebase_storage.dart'; // Import untuk Firebase Storage
import 'dart:io'; // Import untuk File

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String email;

  ProfileScreen({
    required this.userId,
    required this.username,
    required this.email,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  String? _profileImageUrl; // Variabel untuk menyimpan URL gambar profil

  @override
  void initState() {
    super.initState();
    _loadProfileImage(); // Memuat gambar profil saat halaman diinisialisasi
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

  // Fungsi untuk memuat URL gambar profil dari Firestore
  Future<void> _loadProfileImage() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists && userDoc['profileImage'] != null) {
        setState(() {
          _profileImageUrl = userDoc['profileImage'];
        });
      }
    } catch (e) {
      print('Error loading profile image from Firestore: $e');
    }
  }

  // Fungsi untuk membersihkan data dari SharedPreferences saat logout (tidak menghapus data gambar)
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data dari SharedPreferences
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
                        : AssetImage('lib/assets/images/foto1.png') as ImageProvider, // Gambar default
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

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Apakah Anda yakin ingin keluar?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Tidak"),
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
            ),
            TextButton(
              child: const Text("Ya"),
              onPressed: () async {
                // Hapus data SharedPreferences kecuali gambar profil jika perlu
                await _clearUserData(); // Panggil fungsi untuk menghapus data dari SharedPreferences

                // Logout dari Firebase Authentication
                await FirebaseAuth.instance.signOut();

                // Arahkan kembali ke halaman login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false, // Hapus semua halaman sebelumnya
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Bagian Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text(
                    'Profile', // Tulisan "Profile" di kiri atas
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
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
                                : AssetImage('lib/assets/images/foto1.png') as ImageProvider,
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
                              widget.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.email,
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
            ),
            const SizedBox(height: 10), // Mengurangi jarak vertikal antar bagian
            // Bagian Menu Profil
            Expanded(
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05, // Mengurangi margin kiri-kanan
                  vertical: screenHeight * 0.0, // Menggeser sedikit ke atas
                ),
                child: Column(
                  children: [
                    ProfileMenuItem(
                      icon: FontAwesomeIcons.user,
                      text: 'Profil',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileDetailScreen(
                              userId: widget.userId, // Mengirimkan userId
                              username: widget.username, // Mengirimkan username
                              email: widget.email, // Mengirimkan email
                              profileImageUrl: _profileImageUrl, // Mengirimkan URL gambar profil
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ProfileMenuItem(
                      icon: FontAwesomeIcons.signOutAlt, // Ganti ikon untuk logout
                      text: 'Logout Akun', // Ganti teks
                      onTap: _logout, // Panggil fungsi logout
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
