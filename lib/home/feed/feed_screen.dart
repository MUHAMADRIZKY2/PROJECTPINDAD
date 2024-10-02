import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/home/feed/photo_upload_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'CommentScreen.dart'; // Import halaman komentar

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari',
                    prefixIcon: Icon(FontAwesomeIcons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 15, right: 15),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.add_a_photo, color: Colors.blue), // Mengganti ikon ke add_a_photo
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PhotoUploadScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('feed')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var feedItems = snapshot.data!.docs;

                return Column(
                  children: feedItems.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return Column(
                      children: [
                        _buildFeedItem(
                          context,
                          doc.id, // postId
                          data['userName'] ?? 'User',
                          data['location'] ?? 'Location',
                          data['photoUrl'] ?? 'lib/assets/images/user1.png',
                          data['caption'] ?? '',
                          data['likes'] ?? 0,
                          data['comments'] ?? 0, // Jumlah komentar diambil dari feed
                          data['isLiked'] ?? false,
                        ),
                        Divider(height: 1, color: Colors.grey),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedItem(
      BuildContext context,
      String docId,
      String userName,
      String location,
      String imageUrl,
      String caption,
      int likes,
      int comments, // Tambahkan jumlah komentar
      bool isLiked) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(imageUrl),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    location,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              Spacer(),
              PopupMenuButton<String>(
                icon: Icon(FontAwesomeIcons.ellipsisH, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editFeedItem(context, docId, caption);
                  } else if (value == 'delete') {
                    _deleteFeedItem(docId);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Hapus'),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Image.network(
            imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 10),
          Text.rich(
            TextSpan(
              text: '$userName ',
              style: TextStyle(fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: caption,
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          SizedBox(height: 10),

          // Fitur Like dan Comment
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _toggleLike(docId, isLiked, likes);
                },
                child: Row(
                  children: [
                    Icon(
                      isLiked 
                        ? FontAwesomeIcons.solidHeart // Ikon penuh jika disukai
                        : FontAwesomeIcons.heart, // Ikon biasa jika belum disukai
                      color: isLiked ? Colors.red : Colors.grey, // Warna merah jika disukai
                    ),
                    SizedBox(width: 5),
                    Text('$likes'),
                  ],
                ),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentScreen(postId: docId),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.comment,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 5),
                    Text('$comments'), // Tampilkan jumlah komentar
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mengedit feed item
  void _editFeedItem(BuildContext context, String docId, String currentCaption) {
    TextEditingController captionController =
        TextEditingController(text: currentCaption);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Caption'),
          content: TextField(
            controller: captionController,
            decoration: InputDecoration(hintText: 'Edit caption...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                String newCaption = captionController.text.trim();
                if (newCaption.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('feed')
                      .doc(docId)
                      .update({'caption': newCaption});
                  Navigator.pop(context);
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menghapus feed item
  void _deleteFeedItem(String docId) async {
    await FirebaseFirestore.instance.collection('feed').doc(docId).delete();
  }

  // Fungsi untuk toggle like
  void _toggleLike(String docId, bool isLiked, int likes) async {
    var feedDoc = FirebaseFirestore.instance.collection('feed').doc(docId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      var docSnapshot = await transaction.get(feedDoc);
      if (!docSnapshot.exists) {
        throw Exception("Document does not exist");
      }

      int updatedLikes = likes;
      bool updatedIsLiked = !isLiked;

      if (updatedIsLiked) {
        updatedLikes++;
      } else {
        updatedLikes--;
      }

      transaction.update(feedDoc, {
        'likes': updatedLikes,
        'isLiked': updatedIsLiked,
      });
    });
  }
}
