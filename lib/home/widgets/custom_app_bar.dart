import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_application_1/home/kehadiran/attendance_form.dart';
import 'package:flutter_application_1/home/feed/notification_feed_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/home/screens/add_article_screen.dart';

class CustomAppBar extends StatelessWidget {
  final String username;

  const CustomAppBar({
    Key? key,
    required this.username,
  }) : super(key: key);

  void _openWhatsApp() async {
    const whatsappUrl = "https://wa.me/";
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0), // Mengurangi padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'lib/assets/images/logo.png',
                  height: 40, // Memperkecil ukuran logo
                ),
                Row(
                  children: [

                    const SizedBox(width: 8),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.plusCircle, color: Colors.blue, size: 25), // Memperkecil ukuran icon
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddArticleScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.bell, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NotificationFeedScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            children: [
              ClipPath(
                clipper: CustomCurveClipper(),
                child: Container(
                  padding: const EdgeInsets.all(10.0), // Mengurangi padding
                  margin: const EdgeInsets.symmetric(horizontal: 10.0), // Mengurangi margin
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color.fromARGB(255, 10, 90, 156), Color.fromARGB(255, 10, 90, 156)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10.0), // Mengurangi borderRadius
                  ),
                  height: 90, // Mengurangi height
                ),
              ),
              ClipPath(
                clipper: CustomCurveClipper2(),
                child: Container(
                  padding: const EdgeInsets.all(10.0), // Mengurangi padding
                  margin: const EdgeInsets.symmetric(horizontal: 10.0), // Mengurangi margin
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color.fromARGB(255, 106, 62, 182)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10.0), // Mengurangi borderRadius
                  ),
                  height: 90, // Mengurangi height
                ),
              ),
              Positioned.fill(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0), // Mengurangi padding horizontal
                  margin: const EdgeInsets.symmetric(horizontal: 10.0), // Mengurangi margin
                  child: Align(
                    alignment: Alignment.centerLeft, // Memindahkan username ke sebelah kiri
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Selamat Datang",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18, // Ukuran font untuk teks Halloo
                            fontWeight: FontWeight.bold, // Membuat teks Halloo menjadi bold
                          ),
                        ),
                        Text(
                          username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20, // Ukuran font untuk username
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 30.0), // Mengurangi margin
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AttendanceForm()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25), // Sedikit menambah padding tombol
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(19),
                ),
              ),
              child: const Text(
                "Form Kehadiran",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Clipper utama untuk bentuk dasar
class CustomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width - 70, 0);
    path.quadraticBezierTo(
        size.width, size.height / 1, size.width - 150, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

// Clipper tambahan untuk warna di kanan
class CustomCurveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width - 70, 0);
    path.quadraticBezierTo(
        size.width, size.height / 1, size.width - 150, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
