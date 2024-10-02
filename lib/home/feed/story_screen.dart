import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stories'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stories')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var stories = snapshot.data!.docs;

          return ListView(
            children: stories.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return ListTile(
                leading: Image.network(data['imageUrl']),
                title: Text(data['caption']),
                subtitle: Text('Posted at: ${data['timestamp'].toDate()}'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
