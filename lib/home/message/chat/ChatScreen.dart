import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Import untuk membuka URL/WhatsApp

class ChatScreen extends StatefulWidget {
  final String contactName;
  final String contactId;

  const ChatScreen({
    Key? key,
    required this.contactName,
    required this.contactId, required String phoneNumber,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _contactName;
  String _phoneNumber = ""; // Variabel untuk menyimpan nomor telepon

  @override
  void initState() {
    super.initState();
    _contactName = widget.contactName;
    _loadContactData(); // Ambil data kontak, termasuk nomor telepon
  }

  // Fungsi untuk memuat data kontak dari Firestore, termasuk nomor telepon
  void _loadContactData() async {
    try {
      DocumentSnapshot contactSnapshot =
          await _firestore.collection('contacts').doc(widget.contactId).get();
      if (contactSnapshot.exists) {
        Map<String, dynamic> contactData =
            contactSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _phoneNumber = contactData['nomorTelepon'] ?? '';
        });
      }
    } catch (e) {
      print('Gagal memuat data kontak: $e');
    }
  }

  // Fungsi untuk mengirim pesan
  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    try {
      // Kirim pesan ke Firestore
      await _firestore.collection('messages').add({
        'message': _controller.text.trim(),
        'senderName': 'You',
        'receiverName': _contactName,
        'contactId': widget.contactId,
        'timestamp': FieldValue.serverTimestamp(),
        'isMe': true,
      });
      _controller.clear();
      print('Pesan berhasil dikirim.');
    } catch (e) {
      print('Gagal mengirim pesan: $e');
    }
  }

  // Fungsi untuk menampilkan dialog edit kontak
  void _showEditContactDialog() {
    TextEditingController _editController =
        TextEditingController(text: _contactName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Kontak'),
          content: TextField(
            controller: _editController,
            decoration: const InputDecoration(labelText: 'Nama Kontak'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _editContact(_editController.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mengedit kontak di Firestore
  void _editContact(String newName) async {
    try {
      await _firestore
          .collection('contacts')
          .doc(widget.contactId)
          .update({'namaDepan': newName});
      setState(() {
        _contactName = newName;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kontak berhasil diperbarui')),
      );
    } catch (e) {
      print('Gagal mengedit kontak: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengedit kontak: $e')),
      );
    }
  }

  // Fungsi untuk menghapus kontak dari Firestore
  void _deleteContact() async {
    try {
      await _firestore.collection('contacts').doc(widget.contactId).delete();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kontak berhasil dihapus')),
      );
    } catch (e) {
      print('Gagal menghapus kontak: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus kontak: $e')),
      );
    }
  }

  // Fungsi untuk mengirim pesan via WhatsApp
  void _sendMessageViaWhatsApp() async {
    // Pastikan nomor telepon sudah tersedia dan memiliki format yang benar
    if (_phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon tidak ditemukan')),
      );
      return;
    }

    // Format nomor telepon jika diperlukan
    String formattedNumber = _phoneNumber;
    
    // Pastikan kode negara "+62" sudah ada, jika tidak, tambahkan
    if (!formattedNumber.startsWith('+62')) {
      if (formattedNumber.startsWith('0')) {
        formattedNumber = '62' + formattedNumber.substring(1); // Ganti "0" dengan "62"
      } else {
        formattedNumber = '62' + formattedNumber; // Tambahkan "62" jika tidak ada
      }
    }

    // Buat URL WhatsApp dengan nomor telepon yang benar
    final String whatsappUrl =
        'https://wa.me/$formattedNumber?text=Hello%20${widget.contactName}';

    if (await canLaunch(whatsappUrl)) {
      // Buka WhatsApp menggunakan URL
      await launch(whatsappUrl);
    } else {
      // Jika tidak bisa membuka WhatsApp, tampilkan pesan error
      print('Could not launch WhatsApp');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60.0, bottom: 10.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(FontAwesomeIcons.circleChevronLeft,
                      color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Text(
                    _contactName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
                const Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 10,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(FontAwesomeIcons.ellipsisV,
                      color: Colors.black),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditContactDialog();
                    } else if (value == 'delete') {
                      _deleteContact();
                    } else if (value == 'whatsapp') {
                      _sendMessageViaWhatsApp(); // Tambahkan aksi WhatsApp
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit Kontak'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Hapus Kontak'),
                    ),
                    const PopupMenuItem(
                      value: 'whatsapp',
                      child: Text('Kirim via WhatsApp'), // Opsi WhatsApp
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .where('contactId', isEqualTo: widget.contactId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('Error retrieving messages: ${snapshot.error}');
                  return const Center(
                      child: Text('Terjadi kesalahan dalam mengambil data.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print('Tidak ada data atau dokumen kosong');
                  return const Center(child: Text('Tidak ada pesan.'));
                }

                var messages = snapshot.data!.docs;

                print('Messages fetched: ${messages.length}');

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData =
                        messages[index].data() as Map<String, dynamic>;

                    return ChatBubble(
                      message: messageData['message'] ?? '',
                      isMe: messageData['isMe'] ?? false,
                      time: messageData['timestamp'] != null
                          ? (messageData['timestamp'] as Timestamp)
                              .toDate()
                              .toString()
                          : 'Just now',
                      image: 'lib/assets/images/foto1.png',
                      color: messageData['isMe']
                          ? Colors.blue[200]
                          : Colors.pink[100],
                      docId: messages[index].id, // Pass docId for edit/delete
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.smile,
                              color: Colors.grey),
                          onPressed: () {},
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Type here",
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 20.0),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.microphone,
                              color: Colors.grey),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  child: const Icon(FontAwesomeIcons.paperPlane,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;
  final String image;
  final Color? color;
  final String docId;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.time,
    required this.image,
    this.color,
    required this.docId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        // Long press for additional actions (edit/delete, etc.)
        print('Long press on message: $message');
      },
      child: Container(
        margin: isMe
            ? const EdgeInsets.only(left: 60, right: 10, top: 5, bottom: 5)
            : const EdgeInsets.only(left: 10, right: 60, top: 5, bottom: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color ?? Colors.blue[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
            bottomLeft: isMe ? const Radius.circular(10) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 5),
            Text(
              time,
              style: const TextStyle(color: Colors.black54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
