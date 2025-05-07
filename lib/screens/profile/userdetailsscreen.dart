import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoiceapp/services/database_service.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final user = await DatabaseService.instance.getUserById(1);
    setState(() {
      userData = user;
      isLoading = false;
    });
  }

  Future<void> updateUserField(String key, String newValue) async {
    await DatabaseService.instance.updateallUserDetails(
      userId: 1,
      name: key == 'name' ? newValue : null,
      note: key == 'note' ? newValue : null,
      address: key == 'address' ? newValue : null,
      phone: key == 'phone' ? newValue : null,
      website: key == 'website' ? newValue : null,
      email: key == 'email' ? newValue : null,
    );
    await loadUser();
  }

  void showEditDialog(String fieldKey, String label, String? currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $label"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await updateUserField(fieldKey, controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> pickAndSaveImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final db = await DatabaseService.instance.getdatabase();
      await db.update(
        'user',
        {'company_logo_url': picked.path},
        where: 'id = ?',
        whereArgs: [1],
      );
      await loadUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text("No user found."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Company Logo",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: pickAndSaveImage,
                          ),
                        ],
                      ),
                      Center(
                        child: userData!['company_logo_url'] == null
                            ? const Text("No image.")
                            : Image.file(
                                File(userData!['company_logo_url']),
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(height: 20),
                      buildEditableTile("Name", userData!['name'],
                          fieldKey: "name"),
                      buildEditableTile("Email", userData!['email'],
                          fieldKey: "email"),
                      buildEditableTile("Phone", userData!['phone'],
                          fieldKey: "phone"),
                      buildEditableTile("Address", userData!['address'],
                          fieldKey: "address"),
                      buildEditableTile("Note", userData!['note'],
                          fieldKey: "note"),
                      buildEditableTile("Website", userData!['website'],
                          fieldKey: "website"),
                    ],
                  ),
                ),
    );
  }

  Widget buildEditableTile(String title, String? value,
      {String? fieldKey, bool editable = true}) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value ?? "Not available"),
      trailing: editable && fieldKey != null
          ? IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => showEditDialog(fieldKey, title, value),
            )
          : null,
    );
  }
}
