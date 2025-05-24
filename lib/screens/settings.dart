import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person_outline), // outlined version
            title: Text("Profile Settings"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(
                  context, "/prfile"); // fixed typo from "/prfile"
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.description_outlined), // outlined version
            title: Text("Change Template"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, "/commingsoon"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.palette_outlined), // outlined version
            title: Text("Change Theme"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, "/commingsoon"),
          ),
        ],
      ),
    );
  }
}
