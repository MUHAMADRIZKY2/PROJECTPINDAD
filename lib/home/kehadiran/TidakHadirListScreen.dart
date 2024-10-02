import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import untuk formatting tanggal

class TidakHadirListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Tidak Hadir'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Tambahkan padding untuk kenyamanan
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('attendance')
              .where('attendance_status', isEqualTo: 'Tidak hadir')
              .orderBy('timestamp', descending: false) // Urutkan dari yang paling lama
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final tidakHadirDocs = snapshot.data?.docs ?? [];

            if (tidakHadirDocs.isEmpty) {
              return Center(child: Text('Tidak ada yang tidak hadir.'));
            }

            return ListView.builder(
              itemCount: tidakHadirDocs.length,
              itemBuilder: (context, index) {
                var tidakHadirData = tidakHadirDocs[index].data() as Map<String, dynamic>;

                return Card( // Menggunakan Card untuk tampilan yang lebih rapi
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: Text(
                        '${index + 1}', // Menampilkan nomor urut
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      tidakHadirData['username'] ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          'Alasan: ${tidakHadirData['reason'] ?? 'Tidak ada alasan'}',
                          style: TextStyle(color: Colors.black87),
                        ),
                        SizedBox(height: 4),
                        Text(
                          tidakHadirData['timestamp'] != null
                              ? 'Waktu: ${DateFormat('yyyy-MM-dd HH:mm:ss').format((tidakHadirData['timestamp'] as Timestamp).toDate())}'
                              : 'Waktu tidak tersedia',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
