import 'package:flutter/material.dart';
import 'package:flutter_application_1/forgetpassword/passwordbaru.dart';

class ResetPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Ikon panah ke kiri untuk kembali
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        elevation: 0,
        backgroundColor:
            Colors.white, // Background AppBar sesuai dengan background layar
        iconTheme:
            IconThemeData(color: Colors.black), // Warna ikon menjadi hitam
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Warna teks hitam
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Password kamu telah di reset, klik verifikasi kode di bawah ini untuk membuat password baru.',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87), // Warna teks hitam agak pudar
            ),
            SizedBox(height: 16), // Jarak antara teks dan tombol
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateNewPasswordScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(
                    0, 65, 194, 0.85), // Warna tombol biru khas Android
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Center(
                child: Text(
                  'Verifikasi Kode',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white), // Teks putih pada tombol
                ),
              ),
            ),
            Spacer(), // Mendorong konten lainnya ke bawah
          ],
        ),
      ),
      backgroundColor: Colors.white, // Background layar putih
    );
  }
}
