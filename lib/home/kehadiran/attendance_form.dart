import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'hadir_screen.dart';
import 'tidak_hadir_screen.dart';
import 'HadirListScreen.dart'; // Import halaman daftar hadir
import 'TidakHadirListScreen.dart'; // Import halaman daftar tidak hadir

class AttendanceForm extends StatefulWidget {
  @override
  _AttendanceFormState createState() => _AttendanceFormState();
}

class _AttendanceFormState extends State<AttendanceForm> {
  String? _attendance; // Variable untuk menyimpan pilihan kehadiran
  final TextEditingController _nameController = TextEditingController();

  // Fungsi untuk mengirim data ke Firebase Firestore
  Future<void> _submitToFirebase() async {
    try {
      // Simpan data ke Firestore
      await FirebaseFirestore.instance.collection('attendance').add({
        'username': _nameController.text,
        'attendance_status': _attendance ?? '',
        'reason': _attendance == 'Tidak hadir' ? 'Alasan belum diisi' : '',
        'timestamp': FieldValue.serverTimestamp(), // Menyimpan waktu saat disimpan
      });

      print("Data berhasil disimpan ke Firestore.");
    } catch (e) {
      print("Gagal menyimpan data ke Firestore: $e");
      throw Exception('Failed to save data.');
    }
  }

  void _submitForm() async {
    if (_nameController.text.isEmpty) {
      // Validasi untuk memastikan nama pengguna tidak kosong
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Peringatan'),
            content: Text('Nama pengguna tidak boleh kosong.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('TUTUP'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_attendance == 'Hadir' || _attendance == 'Tidak hadir') {
      try {
        await _submitToFirebase(); // Panggil fungsi untuk kirim data ke Firestore
        if (_attendance == 'Hadir') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HadirScreen()),
          );
        } else if (_attendance == 'Tidak hadir') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TidakHadirScreen(username: _nameController.text)), // Pass username
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Gagal mengirim data ke Firestore.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('TUTUP'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Tampilkan pesan kesalahan jika tidak ada pilihan yang dipilih
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Peringatan'),
            content: Text('Harap pilih opsi kehadiran sebelum melanjutkan.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('TUTUP'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Form Pernyataan Kehadiran',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Nama Pengguna',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Masukkan nama pengguna',
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                RadioListTile<String>(
                  title: Text('Hadir'),
                  value: 'Hadir',
                  groupValue: _attendance,
                  onChanged: (value) {
                    setState(() {
                      _attendance = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text('Tidak hadir'),
                  value: 'Tidak hadir',
                  groupValue: _attendance,
                  onChanged: (value) {
                    setState(() {
                      _attendance = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _submitForm,
                child: Text('SELANJUTNYA'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.list_alt, size: 40, color: Colors.blue),
                            onPressed: () {
                              // Arahkan ke halaman daftar hadir
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HadirListScreen()),
                              );
                            },
                          ),
                          Text(
                            'Lihat Daftar Hadir',
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                        ],
                      ),
                      SizedBox(width: 30), // Tambahkan jarak antar ikon
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.warning, size: 40, color: Colors.red),
                            onPressed: () {
                              // Arahkan ke halaman daftar tidak hadir
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TidakHadirListScreen()),
                              );
                            },
                          ),
                          Text(
                            'Lihat Daftar Tidak Hadir',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
