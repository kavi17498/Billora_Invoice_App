import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
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
    // Check if the widget is still in the widget tree before calling setState
    if (!mounted) return;
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
    // You might also want to add a mounted check here
    if (!mounted) return;
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
            child: Text(
              "Cancel",
              style: TextStyle(color: textColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await updateUserField(fieldKey, controller.text);
              Navigator.pop(context);
            },
            child: Text(
              "Save",
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickAndSaveImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return; // 👈 prevent crash if user navigated back

    if (picked != null) {
      final db = await DatabaseService.instance.getdatabase();
      await db.update(
        'user',
        {'company_logo_url': picked.path},
        where: 'id = ?',
        whereArgs: [1],
      );
      if (!mounted) return; // 👈 double-check before setState/loadUser
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
                      Center(
                        child: Text("Company Logo", style: heading),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Stack(
                          children: [
                            // Circular profile picture with border
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: secondaryColor,
                                    width: 3), // Border color & thickness
                                image: userData!['company_logo_url'] == null
                                    ? null
                                    : DecorationImage(
                                        image: FileImage(File(
                                            userData!['company_logo_url'])),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              child: userData!['company_logo_url'] == null
                                  ? const Center(child: Text("No image."))
                                  : null,
                            ),

                            // Positioned edit icon on top right corner of the circle
                            Positioned(
                              right: 0,
                              top: 0,
                              child: InkWell(
                                onTap: pickAndSaveImage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                      buildEditableTile(
                          "Payment Instructions", userData!['note'],
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
