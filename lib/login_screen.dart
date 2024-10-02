import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter_application_1/core.dart';
import 'package:flutter_application_1/home/screens/register_screen.dart';
import 'package:flutter_application_1/home/screens/profile_screen.dart'; // Import ProfileScreen atau HomeScreen sesuai kebutuhan
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordHidden = true; // State untuk mengatur visibilitas password

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Email dan password tidak boleh kosong.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Login menggunakan Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Ambil data pengguna dari Firestore berdasarkan user ID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // Jika pengguna ditemukan, pindah ke HomeScreen/ProfileScreen
      if (userDoc.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              userId: userCredential.user!.uid,
              username: userDoc['username'],
              email: userDoc['email'],
            ),
          ),
        );
      } else {
        _showErrorDialog('Data pengguna tidak ditemukan di database.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showErrorDialog('User tidak ditemukan.');
      } else if (e.code == 'wrong-password') {
        _showErrorDialog('Password salah.');
      } else {
        _showErrorDialog('Login gagal. Silakan coba lagi.');
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Gagal'),
        content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0059FF),
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
                            'lib/assets/images/logo_smp.png',
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
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                          TextField(
                            controller: _emailController,
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
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                          TextField(
                            controller: _passwordController,
                            obscureText: _isPasswordHidden, // Gunakan state untuk atur visibilitas
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordHidden = !_isPasswordHidden; // Toggle visibilitas password
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          SizedBox(height: screenHeight * 0.02),
                          ElevatedButton(
                            onPressed: () {
                              _login();
                            },
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
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
                                padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                  const fallbackUrl = 'https://www.facebook.com/';

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
                                  child: Image.asset('lib/assets/images/facebook.png'),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  const googleUrl = 'https://accounts.google.com/';

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
                                  child: Image.asset('lib/assets/images/google.png'),
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
