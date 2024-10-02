import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/home/feed/feed_screen.dart';
import 'package:flutter_application_1/home/message/chat/ChatHome.dart';
import 'package:flutter_application_1/home/widgets/category_tabs.dart';
import 'package:flutter_application_1/home/widgets/custom_app_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_application_1/home/maps/peta.dart';
import 'package:flutter_application_1/home/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen({super.key, required this.userId, required username, required email});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _layarSaatIni = const HomeContent(username: ''); // Layar awal dengan username default
  String? username;
  String? email;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Ambil data pengguna saat aplikasi dimulai
  }

  void _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Ambil data pengguna dari Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['username'];
            email = userDoc['email'];
            _layarSaatIni = HomeContent(username: username ?? ''); // Update layar dengan username
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  void _gantiLayar(Widget layar) {
    setState(() {
      _layarSaatIni = layar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _layarSaatIni, // Menampilkan layar yang dipilih
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(125, 8, 81, 229),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.house, color: Colors.white),
                      onPressed: () {
                        _gantiLayar(HomeContent(username: username ?? ''));
                      },
                    ),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.locationDot, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                      },
                    ),
                    IconButton(
                      icon: Stack(
                        children: <Widget>[
                          const Icon(FontAwesomeIcons.envelope, color: Colors.white),
                          Positioned(
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: const Text(
                                '3', // Angka badge untuk Pesan
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                      ),
                      onPressed: () {
                        _gantiLayar(const ChatHome(chatScreen: 'Nama Kontak'));
                      },
                    ),
                    IconButton(
                      icon: Stack(
                        children: <Widget>[
                          const Icon(FontAwesomeIcons.fire, color: Colors.white),
                          Positioned(
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: const Text(
                                '2', // Angka badge untuk Feed
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                      ),
                      onPressed: () {
                        _gantiLayar(FeedScreen());
                      },
                    ),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.user, color: Colors.white),
                      onPressed: () {
                        // Cek apakah data pengguna tersedia sebelum navigasi
                        if (widget.userId.isNotEmpty && username != null && email != null) {
                           _gantiLayar(ProfileScreen(
                            userId: widget.userId,
                            username: username!,
                            email: email!,
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Loading user data, please wait...')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final String username; // Terima username dari HomeScreen
  const HomeContent({super.key, required this.username});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String selectedCategory = 'Kesehatan'; // Kategori awal

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category; // Update kategori yang dipilih
    });
  }

  // Fungsi untuk menghapus postingan dari Firestore
  void _deletePost(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('articles').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artikel berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus artikel: $e')),
      );
    }
  }

  // Fungsi untuk mengedit postingan - menampilkan dialog input untuk mengedit
  void _editPost(String docId, Map<String, dynamic> data) {
    TextEditingController titleController = TextEditingController(text: data['title']);
    TextEditingController contentController = TextEditingController(text: data['content']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Artikel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Konten'),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                // Perbarui data di Firestore
                try {
                  await FirebaseFirestore.instance.collection('articles').doc(docId).update({
                    'title': titleController.text,
                    'content': contentController.text,
                  });
                  Navigator.pop(context); // Tutup dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Artikel berhasil diperbarui')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal memperbarui artikel: $e')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(username: widget.username), // Akses username dari widget
        const SizedBox(height: 10),
        // Tampilkan kategori menggunakan CategoryTabs
        CategoryTabs(
          onCategorySelected: _onCategorySelected, // Callback saat kategori dipilih
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('articles')
                .where('category', isEqualTo: selectedCategory) // Ambil data sesuai kategori
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No articles found.'));
              }

              return ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleScreen(
                            title: data['title'] ?? 'No Title',
                            author: data['author'] ?? 'Unknown Author',
                            date: (data['timestamp'] as Timestamp).toDate().toString(),
                            content: data['content'] ?? 'No Content',
                            imagePath: data['imageUrl'] ?? '',
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Menampilkan gambar dengan ukuran dan border yang diatur
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15), // Mengatur border radius
                            child: Container(
                              height: 200, // Atur tinggi gambar
                              width: double.infinity, // Atur lebar agar sesuai kontainer
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey), // Menambahkan border
                              ),
                              child: Image.network(
                                data['imageUrl']?.replaceAll('"', '') ?? '',
                                fit: BoxFit.cover, // Mengatur gambar agar sesuai dengan kontainer
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text('Gagal memuat gambar');
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              data['title'] ?? 'No Title',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Menampilkan author dan tanggal di sebelah kiri
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'by ${data['author'] ?? 'Unknown Author'}',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      (data['timestamp'] as Timestamp).toDate().toString(),
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                // Menambahkan ikon titik tiga untuk opsi edit dan hapus
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editPost(doc.id, data);
                                    } else if (value == 'delete') {
                                      _deletePost(doc.id);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Ubah'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Hapus'),
                                    ),
                                  ],
                                  icon: const Icon(Icons.more_vert),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ArticleScreen extends StatelessWidget {
  final String title;
  final String author;
  final String date;
  final String content;
  final String imagePath;

  const ArticleScreen({
    Key? key,
    required this.title,
    required this.author,
    required this.date,
    required this.content,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imagePath.isNotEmpty ? Image.network(
              imagePath.replaceAll('"', ''), // Menghapus tanda kutip jika ada
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Text('Gagal memuat gambar');
              },
            ) : Container(), // Menampilkan kontainer kosong jika tidak ada gambar
            const SizedBox(height: 16.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  author,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              content,
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
