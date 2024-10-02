import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import untuk formatting tanggal

class HadirListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Kehadiran'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('attendance_status', isEqualTo: 'Hadir')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final hadirDocs = snapshot.data?.docs ?? [];

          if (hadirDocs.isEmpty) {
            return Center(child: Text('Tidak ada yang hadir.'));
          }

          return ListView.builder(
            itemCount: hadirDocs.length,
            itemBuilder: (context, index) {
              var hadirData = hadirDocs[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    '${index + 1}', // Menampilkan nomor urut
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(hadirData['username'] ?? 'Unknown'),
                subtitle: Text(
                  hadirData['timestamp'] != null
                      ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                          (hadirData['timestamp'] as Timestamp).toDate())
                      : 'Waktu tidak tersedia',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
