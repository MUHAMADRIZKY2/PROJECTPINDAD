import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentScreen extends StatefulWidget {
  final String postId;

  CommentScreen({required this.postId});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  // Fungsi untuk mengirim komentar
  void _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      // Tambahkan komentar baru ke subcollection 'comments' di dokumen feed
      await FirebaseFirestore.instance
          .collection('feed')
          .doc(widget.postId)
          .collection('comments') // Subcollection untuk komentar
          .add({
        'comment': _commentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Bersihkan textfield setelah komentar terkirim
      _commentController.clear();

      // Perbarui jumlah komentar di dokumen feed
      await FirebaseFirestore.instance
          .collection('feed')
          .doc(widget.postId)
          .update({
        'comments': FieldValue.increment(1) // Tambahkan 1 ke jumlah komentar
      });
    } catch (e) {
      print('Failed to post comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('feed')
                  .doc(widget.postId)
                  .collection('comments') // Subcollection untuk komentar
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Belum ada komentar.'));
                }

                var comments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    var commentData = comments[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(commentData['comment'] ?? ''),
                      subtitle: Text(commentData['timestamp'] != null
                          ? (commentData['timestamp'] as Timestamp).toDate().toString()
                          : 'Unknown time'),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan komentar...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
