import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'berhasil_screen.dart'; // Layar ketika berhasil

class TidakHadirScreen extends StatefulWidget {
  final String username;

  TidakHadirScreen({required this.username});

  @override
  _TidakHadirScreenState createState() => _TidakHadirScreenState();
}

class _TidakHadirScreenState extends State<TidakHadirScreen> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false; // Menambahkan indikator loading

  // Fungsi untuk mengirim data ketidakhadiran ke Firebase Firestore
  Future<void> _submitReasonToFirestore() async {
    setState(() {
      _isLoading = true; // Mengaktifkan loading saat proses pengiriman dimulai
    });
    
    try {
      // Simpan data ketidakhadiran ke Firestore
      await FirebaseFirestore.instance.collection('attendance').add({
        'username': widget.username, // Menggunakan username dari input sebelumnya
        'attendance_status': 'Tidak hadir',
        'reason': _reasonController.text,
        'timestamp': FieldValue.serverTimestamp(), // Menyimpan waktu saat data disimpan
      });

      print("Reason successfully saved to Firestore.");
      // Menampilkan halaman berhasil setelah alasan dikirim
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BerhasilScreen(),
        ),
      );
    } catch (e) {
      // Tampilkan pesan kesalahan jika gagal
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Gagal mengirim alasan. Silakan coba lagi.'),
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
    } finally {
      setState(() {
        _isLoading = false; // Menonaktifkan loading setelah proses selesai
      });
    }
  }

  // Fungsi untuk memvalidasi dan mengirim form
  void _submitForm() {
    if (_reasonController.text.isEmpty) {
      // Tampilkan peringatan jika alasan kosong
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Peringatan'),
            content: Text('Alasan tidak boleh kosong.'),
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

    // Jika valid, lanjutkan pengiriman data
    _submitReasonToFirestore();
  }

  @override
  void dispose() {
    _reasonController.dispose(); // Dispose controller untuk menghindari memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alasan Ketidakhadiran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Tidak Hadir',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'Alasan',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm, // Tombol dinonaktifkan saat loading
              child: _isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text('KIRIM'),
            ),
          ],
        ),
      ),
    );
  }
}
