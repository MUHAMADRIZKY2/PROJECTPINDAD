import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'firebase_options.dart'; // Import konfigurasi Firebase yang di-generate
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/loading_page.dart';
import 'package:flutter_application_1/home/screens/register_screen.dart';
import 'package:flutter_application_1/home/screens/home_screen.dart'; // Pastikan ini diimpor

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Inisialisasi sebelum runApp
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Inisialisasi Firebase
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      routes: {
        // Tangkap argumen userId yang dikirim ke HomeScreen
        '/home': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return HomeScreen(
            userId: userId, username: null, email: null, // Kirim hanya userId ke HomeScreen
          );
        },
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Menampilkan halaman loading selama 3 detik sebelum navigasi ke LoginScreen
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingPage(pageIndex: 3),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Fungsi untuk melakukan login
  Future<void> _login(BuildContext context, String email, String password) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Dapatkan userId dari userCredential
      final userId = userCredential.user?.uid ?? '';

      // Jika login berhasil, pindah ke HomeScreen dengan userId
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: userId, // Kirim hanya userId
      );
    } catch (e) {
      // Jika login gagal, tampilkan pesan error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Gagal'),
          content: Text('Email atau password salah.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0059FF), // Warna biru pada background
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.12),
                          Image.asset(
                            'lib/assets/images/logo_smp.png', // Ganti dengan path logo Anda
                            height: screenHeight * 0.18,
                          ),
                          SizedBox(height: screenHeight * 0.06),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 3,
                            color: Colors.black,
                            margin: EdgeInsets.only(bottom: 10),
                          ),
                          Text(
                            'MASUK',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 4, 0, 0),
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            'Selamat datang di Room Pension\nSMPN 1 Bandung',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Email',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0)),
                            ),
                          ),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Password',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0)),
                            ),
                          ),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: Icon(Icons.visibility_off),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          SizedBox(height: screenHeight * 0.02),
                          ElevatedButton(
                            onPressed: () {
                              _login(context, emailController.text, passwordController.text);
                            },
                            child: Text(
                              'Masuk',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 7, 80, 205),
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('atau'),
                              ),
                              Expanded(child: Divider(color: Colors.grey)),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Tidak memiliki akun?'),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegisterScreen(),
                                    ),
                                  );
                                },
                                child: Text('Daftar'),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  const fbProtocolUrl = 'fb://profile';
                                  const fallbackUrl =
                                      'https://www.facebook.com/';

                                  try {
                                    final bool launched = await launchUrl(
                                      Uri.parse(fbProtocolUrl),
                                      mode: LaunchMode.externalApplication,
                                    );
                                    if (!launched) {
                                      await launchUrl(
                                        Uri.parse(fallbackUrl),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  } catch (e) {
                                    throw 'Tidak bisa membuka $fallbackUrl';
                                  }
                                },
                                icon: SizedBox(
                                  width: screenWidth * 0.12,
                                  height: screenWidth * 0.12,
                                  child: Image.asset(
                                      'lib/assets/images/facebook.png'),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  const googleUrl =
                                      'https://accounts.google.com/';

                                  try {
                                    final bool launched = await launchUrl(
                                      Uri.parse(googleUrl),
                                      mode: LaunchMode.externalApplication,
                                    );
                                    if (!launched) {
                                      throw 'Tidak bisa membuka $googleUrl';
                                    }
                                  } catch (e) {
                                    throw 'Tidak bisa membuka $googleUrl';
                                  }
                                },
                                icon: SizedBox(
                                  width: screenWidth * 0.08,
                                  height: screenWidth * 0.08,
                                  child: Image.asset(
                                      'lib/assets/images/google.png'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.01),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
