import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscure = true; // Status untuk menyembunyikan/memperlihatkan password

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'username': usernameController.text,
        'email': emailController.text,
      });

      print('User terdaftar dan data disimpan ke Firestore: ${userCredential.user}');
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Gagal mendaftar';
      if (e.code == 'weak-password') {
        errorMessage = 'Password yang diberikan terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Akun sudah ada untuk email tersebut.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Alamat email tidak valid.';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Pendaftaran Gagal'),
          content: Text('Kesalahan: $errorMessage'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Kesalahan'),
          content: Text('Terjadi kesalahan tak terduga. Silakan coba lagi nanti.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                            'DAFTAR',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 4, 0, 0),
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildTextField(
                                  label: 'Username',
                                  controller: usernameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Silakan masukkan username Anda';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.015),
                                _buildTextField(
                                  label: 'Email',
                                  controller: emailController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Silakan masukkan email Anda';
                                    }
                                    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                    if (!emailRegExp.hasMatch(value)) {
                                      return 'Silakan masukkan email yang valid';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.015),
                                _buildTextField(
                                  label: 'Password',
                                  controller: passwordController,
                                  obscureText: _isObscure,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Silakan masukkan password Anda';
                                    }
                                    return null;
                                  },
                                  isPasswordField: true,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _isObscure = !_isObscure; // Toggle visibilitas
                                    });
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                _isLoading
                                    ? CircularProgressIndicator()
                                    : ElevatedButton(
                                        onPressed: _register,
                                        child: Text(
                                          'Daftar',
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
                                    Text('Sudah mempunyai akun?'),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Masuk'),
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
                                          throw 'Tidak dapat membuka $fallbackUrl';
                                        }
                                      },
                                      icon: SizedBox(
                                        width: screenWidth * 0.12,
                                        height: screenWidth * 0.12,
                                        child: Image.asset(
                                          'lib/assets/images/facebook.png',
                                        ),
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
                                            throw 'Tidak dapat membuka $googleUrl';
                                          }
                                        } catch (e) {
                                          throw 'Tidak dapat membuka $googleUrl';
                                        }
                                      },
                                      icon: SizedBox(
                                        width: screenWidth * 0.08,
                                        height: screenWidth * 0.08,
                                        child: Image.asset(
                                          'lib/assets/images/google.png',
                                        ),
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool obscureText = false,
    VoidCallback? onToggleVisibility, // Callback untuk toggle visibilitas
    bool isPasswordField = false, // Menandai apakah ini adalah field password
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.black),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: 'Masukkan $label Anda',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: isPasswordField // Tampilkan ikon hanya untuk field password
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: onToggleVisibility, // Panggil callback toggle
                  )
                : null,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
