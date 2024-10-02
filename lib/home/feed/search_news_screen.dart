import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchNewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search News'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/user1.png'),
            ),
            title: Text('Mas Rudy'),
            subtitle: Text('Bandung'),
            trailing: Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/user2.png'),
            ),
            title: Text('Mas Raihan'),
            subtitle: Text('Bandung'),
            trailing: Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/user3.png'),
            ),
            title: Text('Mba Lulu'),
            subtitle: Text('Bandung'),
            trailing: Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
