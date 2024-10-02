import 'package:flutter/material.dart'; // Import halaman Ubah Password
import 'profile_detail_screen.dart'; // Import halaman Profile Detail
import 'package:flutter_application_1/main.dart'; // Pastikan Anda mengimpor main.dart yang berisi LoginScreen

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onToggleDarkMode;

  SettingsScreen({required this.isDarkMode, required this.onToggleDarkMode});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Pengaturan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold, // Menjadikan teks tebal (bold)
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, // Membuat garis selebar layar
              child: Divider(
                color: Colors.black, // Warna garis
                thickness: 1, // Ketebalan garis
                height: 1, // Tinggi Divider
              ),
            ),
            SizedBox(height: 8), // Jarak antara garis dan teks
            Text(
              'Pengaturan Akun',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.black, width: 2),
              ),
              title: Text('Edit Profil'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigasi ke halaman Edit Profil
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProfileDetailScreen(userId: '', username: '', email: '',),
                ));
              },
            ),
            SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.black, width: 2),
              ),            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Arahkan ke layar LoginScreen di main.dart
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => SplashScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Text('Keluar'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.black, width: 2),
                    ),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    elevation: 0,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('Munculkan Notifikasi'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: Color.fromRGBO(81, 0, 253, 1),
            ),
            SwitchListTile(
              title: Text('Mode Gelap'),
              value: widget.isDarkMode,
              onChanged: (bool value) {
                widget.onToggleDarkMode(value);
              },
              activeColor: Color.fromRGBO(81, 0, 253, 1),
            ),
          ],
        ),
      ),
    );
  }
}
