import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:contacts_service/contacts_service.dart'; // Import contacts_service
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _jabatanController = TextEditingController();
  final TextEditingController _namaDepanController = TextEditingController();
  final TextEditingController _namaBelakangController = TextEditingController();
  final TextEditingController _nomorTeleponController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  String? _selectedJabatan;

  // Fungsi untuk menyimpan kontak ke Firestore
  void _saveContact() async {
    try {
      // Validasi input
      if (_namaDepanController.text.trim().isEmpty ||
          _nomorTeleponController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama depan dan nomor telepon harus diisi')),
        );
        return;
      }

      // Menyimpan data kontak ke koleksi 'contacts' di Firestore
      await FirebaseFirestore.instance.collection('contacts').add({
        'namaDepan': _namaDepanController.text.trim(),
        'namaBelakang': _namaBelakangController.text.trim(),
        'nomorTelepon': _nomorTeleponController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'jabatan': _selectedJabatan ?? 'Tidak Ditentukan',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Setelah kontak disimpan, buka WhatsApp
      final String phoneNumber = _nomorTeleponController.text.trim();
      await _openWhatsApp(phoneNumber);

      // Kembali ke halaman chat setelah menambah kontak
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kontak berhasil disimpan dan WhatsApp terbuka')),
      );
      Navigator.pop(context);
    } catch (e) {
      // Menampilkan error jika terjadi kesalahan saat menyimpan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan kontak: $e')),
      );
    }
  }

  // Fungsi untuk membuka WhatsApp
  Future<void> _openWhatsApp(String phoneNumber) async {
    // Hapus angka "0" di awal nomor jika ada
    if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1); // Menghilangkan angka pertama "0"
    }

    // Tambahkan kode negara jika tidak ada (contoh: Indonesia +62)
    if (!phoneNumber.startsWith('62')) {
      phoneNumber = '62' + phoneNumber;
    }

    // Membuat URL WhatsApp menggunakan format yang benar
    final String whatsappUrl = "https://wa.me/$phoneNumber";
    
    // Cek apakah URL bisa dibuka
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      // Buka WhatsApp melalui aplikasi eksternal
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    } else {
      // Jika tidak dapat membuka WhatsApp, tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
      );
    }
  }

  // Fungsi untuk mengambil nomor telepon dari daftar kontak dengan fitur pencarian
  Future<void> _selectPhoneNumberFromContacts() async {
    // Meminta izin akses kontak
    if (await Permission.contacts.request().isGranted) {
      // Mendapatkan daftar kontak dari perangkat
      Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
      List<Contact> contactList = contacts.toList();
      List<Contact> filteredContacts = contactList; // Daftar kontak yang difilter

      // State untuk mengelola input pencarian
      String searchQuery = '';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Pilih Kontak'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Input pencarian
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Cari Kontak',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                          filteredContacts = contactList.where((contact) {
                            String contactName = contact.displayName?.toLowerCase() ?? 'Tidak Diketahui';
                            return contactName.contains(searchQuery);
                          }).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    // Menampilkan daftar kontak
                    Expanded(
                      child: Container(
                        width: double.maxFinite,
                        child: ListView.builder(
                          itemCount: filteredContacts.length,
                          itemBuilder: (BuildContext context, int index) {
                            Contact contact = filteredContacts[index];
                            return ListTile(
                              title: Text(contact.displayName ?? 'Tidak Diketahui'),
                              subtitle: Text(
                                contact.phones!.isNotEmpty
                                    ? contact.phones!.first.value ?? 'Tidak ada nomor'
                                    : 'Tidak ada nomor',
                              ),
                              onTap: () {
                                if (contact.phones!.isNotEmpty) {
                                  _nomorTeleponController.text = contact.phones!.first.value ?? '';
                                }
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      // Menampilkan pesan jika izin ditolak
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin akses kontak ditolak')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Kontak',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.circleChevronLeft, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigasi kembali ke layar sebelumnya
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.plusCircle, color: Colors.black),
            onPressed: _saveContact, // Panggil fungsi _saveContact saat tombol ditekan
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('lib/assets/images/foto2.png'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _namaDepanController,
                        decoration: const InputDecoration(
                          labelText: 'Nama depan',
                          labelStyle: TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _namaBelakangController,
                        decoration: const InputDecoration(
                          labelText: 'Nama belakang',
                          labelStyle: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildLabeledContainer(
              label: 'Nomor Telepon',
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nomorTeleponController,
                      decoration: const InputDecoration(
                        prefixText: '+62 ', // Kode negara Indonesia
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      keyboardType: TextInputType.phone, // Menambahkan keyboard khusus nomor telepon
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.contacts),
                    onPressed: _selectPhoneNumberFromContacts, // Panggil fungsi pemilihan nomor telepon
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildLabeledContainer(
              label: 'Alamat',
              child: TextField(
                controller: _alamatController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildLabeledContainer(
              label: 'Jabatan Pekerjaan',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedJabatan,
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'Manager',
                      child: Text('Manager'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Supervisor',
                      child: Text('Supervisor'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Staff',
                      child: Text('Staff'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Hrd',
                      child: Text("Hrd"),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Security',
                      child: Text("Security"),
                    ),
                    DropdownMenuItem<String>(
                      value: 'CEO',
                      child: Text("CEO"),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Software Engineer',
                      child: Text("Software Engineer"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedJabatan = value;
                      _jabatanController.text = value ?? '';
                    });
                  },
                  hint: const Text('Pilih Jabatan Pekerjaan'),
                  icon: const Icon(FontAwesomeIcons.chevronDown, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledContainer({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.grey),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: child,
        ),
      ],
    );
  }
}
