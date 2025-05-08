import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Profile Settings"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context,
                  "/prfile"); // adjust to "/profile" if that's the correct route
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.description),
            title: Text("Change Template"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, "/commingsoon"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.palette),
            title: Text("Change Theme"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, "/commingsoon"),
          ),
        ],
      ),
    );
  }
}
