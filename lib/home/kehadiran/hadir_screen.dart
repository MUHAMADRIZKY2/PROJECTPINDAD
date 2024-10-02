import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/screens/home_screen.dart';

class HadirScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Konfirmasi Kehadiran'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text(
              'Berhasil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Terima kasih telah mengisi formulir kehadiran.'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Log event ke backend jika diperlukan sebelum kembali ke home
                // _logAttendanceConfirmation(); // Fungsi opsional untuk logging

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(userId: '', username: null, email: null,)),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text('KEMBALI KE HOME'),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi opsional untuk mengirim log ke backend jika diinginkan
  // void _logAttendanceConfirmation() async {
  //   // Kirim data ke server atau lakukan tindakan lain
  // }
}
