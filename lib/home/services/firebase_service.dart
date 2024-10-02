// TODO Implement this library.// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addArticle(String title, String author, String content, String imageUrl) async {
  try {
    await FirebaseFirestore.instance.collection('articles').add({
      'title': title,
      'author': author,
      'date': DateTime.now().toString(),
      'content': content,
      'imageUrl': imageUrl,
    });
    print('Article added successfully');
  } catch (e) {
    print('Error adding article: $e');
  }
}
