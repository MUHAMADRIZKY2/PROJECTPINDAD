import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter_application_1/home/message/chat/ChatScreen.dart';
import 'package:flutter_application_1/home/message/contact/addContactScreen.dart';
import 'package:flutter_application_1/home/screens/home_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatHome extends StatefulWidget {
  final String chatScreen;

  const ChatHome({Key? key, required this.chatScreen}) : super(key: key);

  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen(userId: '', username: null, email: null,)),
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Pesan",
              style: TextStyle(color: Colors.black),
            ),
            Image.asset(
              'lib/assets/images/wa.png',
              width: 50,
              height: 50,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Input pencarian
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
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
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Cari",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(20.0, 0.0, 8.0, 0.0),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 12.0, right: 32.0),
                    child: Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('contacts')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Tidak ada kontak.'));
                  }

                  var contacts = snapshot.data!.docs;

                  // Filter berdasarkan pencarian
                  var filteredContacts = contacts.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    var fullName = '${data['namaDepan']} ${data['namaBelakang']}'
                        .toLowerCase();
                    return fullName.contains(_searchQuery);
                  }).toList();

                  // Log untuk memastikan data diterima
                  debugPrint('Kontak yang diambil: ${filteredContacts.length}');

                  return ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      var contactData =
                          filteredContacts[index].data() as Map<String, dynamic>;

                      // Log data kontak yang diambil untuk debugging
                      debugPrint(
                          'Kontak: ${contactData['namaDepan']} ${contactData['namaBelakang']} - ${contactData['nomorTelepon']}');

                      return _buildListTile(
                        context,
                        name:
                            '${contactData['namaDepan']} ${contactData['namaBelakang']}',
                        message: contactData['nomorTelepon'] ?? '',
                        color: Colors.green,
                        image:
                            'lib/assets/images/default.png', // Path default gambar
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                contactName:
                                    '${contactData['namaDepan']} ${contactData['namaBelakang']}',
                                contactId: filteredContacts[index].id, phoneNumber: '',
                              ),
                            ),
                          );
                        },
                        docId: filteredContacts[index].id, // ID Dokumen untuk hapus kontak
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: buildFAB(context),
      ),
    );
  }

  Widget buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddContactScreen(),
          ),
        );
      },
      backgroundColor: Colors.blue,
      child: const Icon(
        FontAwesomeIcons.plus,
        color: Colors.white,
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String name,
    required String message,
    required Color color,
    required String image,
    required String docId, // ID Dokumen untuk menghapus
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(image),
        ),
        title: Text(
          name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .where('contactId', isEqualTo: docId)
              .orderBy('timestamp', descending: true)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Memuat...');
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Text('Tidak ada pesan.');
            }

            var lastMessage = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            return Text(
              lastMessage['message'] ?? '',
              style: const TextStyle(fontSize: 16),
            );
          },
        ),

        onTap: onTap,
      ),
    );
  }

  // Fungsi untuk menghapus kontak berdasarkan ID dokumen
  void _deleteContact(BuildContext context, String docId) {
    FirebaseFirestore.instance
        .collection('contacts')
        .doc(docId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kontak berhasil dihapus')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus kontak: $error')),
      );
    });
  }
}
