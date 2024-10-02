import 'package:flutter/material.dart';

class SearchChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Chat'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/user1.png'),
          ),
          title: Text('James Boston'),
          subtitle: Text('Apa kabar?'),
          trailing: Icon(Icons.circle, color: Colors.green, size: 12),
        ),
      ),
    );
  }
}
