import 'package:flutter/material.dart';
import 'package:helios_application/DataTableExample.dart';

import 'EmailTemplateForm.dart';
import 'MyHomePage.dart';
import 'SendEmailScreen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text('John Doe'),
            accountEmail: Text('john@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  AssetImage('assets/avatar.jpg'), // Add your avatar image
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Email Sender'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EmailComposeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('All Customer'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DataTableExample()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Template'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EmailTemplateForm()),
              );
            },
          ),
        ],
      ),
    );
  }
}
