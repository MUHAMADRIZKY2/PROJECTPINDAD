import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/feed/feed_screen.dart';
import 'package:flutter_application_1/home/message/chat/chathome.dart';
import 'package:flutter_application_1/home/screens/profile_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final LatLng initialCenter = const LatLng(-6.914744, 107.609810);
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(vsync: this);

  final TextEditingController _searchController = TextEditingController();
  LatLng? userLocation;
  LatLng? reunionLocation;
  String currentAddress = ""; // Untuk menyimpan alamat dari reverse geocoding
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  get http => null; // Firestore instance

  @override
  void initState() {
    super.initState();
    _loadReunionLocationFromFirestore(); // Ambil data lokasi dari Firestore saat aplikasi dimulai
    _determinePosition(); // Ambil lokasi pengguna saat ini
  }

  // Fungsi untuk mengambil data lokasi reuni dari Firestore
  Future<void> _loadReunionLocationFromFirestore() async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('locations')
          .doc('reunion_location')
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        // Pastikan tipe data adalah double
        double lat = data['latitude'] is double ? data['latitude'] : (data['latitude'] as num).toDouble();
        double lon = data['longitude'] is double ? data['longitude'] : (data['longitude'] as num).toDouble();
        String address = data['address'];

        setState(() {
          reunionLocation = LatLng(lat, lon);
          currentAddress = address;
        });

        print("Reunion location loaded: $currentAddress ($lat, $lon)");
      } else {
        print("Document does not exist");
      }
    } catch (e) {
      print("Failed to load reunion location: $e");
    }
  }

  // Fungsi untuk menyimpan lokasi reuni ke Firestore
  Future<void> _saveReunionLocationToFirestore(
      String address, LatLng location) async {
    await _firestore.collection('locations').doc('reunion_location').set({
      'address': address,
      'latitude': location.latitude,
      'longitude': location.longitude,
    });

    setState(() {
      reunionLocation = location;
      currentAddress = address;
    });

    print("Reunion location saved: $address (${location.latitude}, ${location.longitude})");
  }

  // Fungsi untuk mendapatkan lokasi pengguna saat ini
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
      _animatedMapController.animateTo(
        dest: userLocation!,
        zoom: 15.0,
      );
    });

    // Mulai memantau lokasi pengguna secara real-time
    _startTrackingLocation();
  }

  // Fungsi untuk memantau lokasi pengguna secara real-time
  void _startTrackingLocation() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update posisi setiap 10 meter
      ),
    ).listen((Position position) {
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });

      // Cek apakah pengguna sudah sampai di tujuan
      if (reunionLocation != null) {
        _checkProximity(reunionLocation!);
      }
    });
  }

  // Fungsi untuk mendapatkan alamat dari koordinat
  Future<void> _getAddressFromCoordinates(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          currentAddress =
              "${placemark.street}, ${placemark.subLocality}, ${placemark.locality}"; // Sesuaikan format alamat
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        currentAddress = "Alamat tidak ditemukan";
      });
    }
  }

  // Fungsi untuk mencari lokasi berdasarkan nama
  Future<void> _searchLocation(String query) async {
    final url =
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final double lat = double.parse(data[0]['lat']);
          final double lon = double.parse(data[0]['lon']);
          final LatLng newLocation = LatLng(lat, lon);

          // Simpan lokasi reuni ke Firestore
          _saveReunionLocationToFirestore(query, newLocation);

          _moveToLocation(newLocation);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lokasi tidak ditemukan.'),
            ),
          );
        }
      } else {
        throw Exception('Failed to load location');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mencari lokasi.'),
        ),
      );
    }
  }

  // Fungsi untuk memindahkan kamera peta ke lokasi tertentu
  void _moveToLocation(LatLng location) {
    _animatedMapController.animateTo(
      dest: location,
      zoom: 15.0,
    );
  }

  // Fungsi untuk membuka Google Maps dengan lokasi tertentu
  Future<void> _openGoogleMaps(LatLng location) async {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open Google Maps.';
    }
  }

  // Fungsi untuk mengecek apakah pengguna berada di dekat lokasi tujuan
  Future<void> _checkProximity(LatLng targetLocation) async {
    double distance = Geolocator.distanceBetween(
      userLocation!.latitude,
      userLocation!.longitude,
      targetLocation.latitude,
      targetLocation.longitude,
    );

    // Jika pengguna berada dalam radius 50 meter dari tujuan
    if (distance <= 50) {
      // Dapatkan alamat dari koordinat ketika sudah berada di tujuan
      await _getAddressFromCoordinates(targetLocation);

      // Navigasi ke halaman konfirmasi dengan alamat yang didapat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationPage(address: currentAddress),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _animatedMapController.mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 15.0,
              onMapReady: () {
                _animatedMapController.animateTo(
                  dest: initialCenter,
                  zoom: 15.0,
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  if (reunionLocation != null)
                    Marker(
                      point: reunionLocation!,
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  if (userLocation != null)
                    Marker(
                      point: userLocation!,
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 40.0,
            left: 20.0,
            right: 20.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Kemana anda mau pergi?',
                  icon: Icon(Icons.search),
                ),
                onSubmitted: (value) {
                  _searchLocation(value);
                },
              ),
            ),
          ),
          Positioned(
            bottom: 100.0,
            left: 20.0,
            right: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (reunionLocation != null) {
                      _moveToLocation(reunionLocation!);
                      _openGoogleMaps(reunionLocation!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lokasi reuni belum ditentukan.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 65, 194, 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    textStyle: const TextStyle(fontSize: 18.0),
                  ),
                  child: const Text(
                    'Lokasi Reuni',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _determinePosition(); // Panggil fungsi untuk mendapatkan lokasi terbaru
                    if (userLocation != null) {
                      _moveToLocation(userLocation!);
                      _openGoogleMaps(userLocation!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 65, 194, 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    textStyle: const TextStyle(fontSize: 18.0),
                  ),
                  child: const Text(
                    'Lokasi Anda',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomNavbar(
                userId: 'USER_ID', // Ganti dengan userId yang sebenarnya
                username: 'USERNAME', // Ganti dengan username yang sebenarnya
                email: 'EMAIL', // Ganti dengan email yang sebenarnya
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget CustomNavbar
class CustomNavbar extends StatelessWidget {
  final String userId;
  final String username;
  final String email;

  const CustomNavbar({
    Key? key,
    required this.userId,
    required this.username,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color.fromARGB(125, 8, 81, 229),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.house, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Kembali ke HomeScreen
            },
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.locationDot, color: Colors.white),
            onPressed: () {
              // Tetap di halaman MyHomePage
            },
          ),
          IconButton(
            icon: Stack(
              children: <Widget>[
                const Icon(FontAwesomeIcons.envelope, color: Colors.white),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatHome(chatScreen: 'Nama Kontak'),
                ),
              );
            },
          ),
          IconButton(
            icon: Stack(
              children: <Widget>[
                const Icon(FontAwesomeIcons.fire, color: Colors.white),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.user, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    userId: userId,
                    username: username,
                    email: email,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Halaman konfirmasi ketika sudah tiba di lokasi reuni
class ConfirmationPage extends StatelessWidget {
  final String address;

  const ConfirmationPage({Key? key, required this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ANDA SUDAH BERADA DITUJUAN',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.purple.shade100, Colors.purple],
                  radius: 1.0,
                ),
              ),
              padding: const EdgeInsets.all(50),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              address,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text('TANDAI HADIR'),
            ),
          ],
        ),
      ),
    );
  }
}
