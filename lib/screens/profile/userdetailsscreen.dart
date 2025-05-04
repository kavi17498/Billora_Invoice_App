import 'dart:io'; // Needed to use File
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text("No user found."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      // Show logo image if file path exists
                      if (userData!['company_logo_url'] != null &&
                          userData!['company_logo_url'].toString().isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Company Logo",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Image.file(
                                File(userData!['company_logo_url']),
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text(
                                    "Image failed to load.",
                                    style: TextStyle(color: Colors.red),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      buildDetailTile("Name", userData!['name']),
                      buildDetailTile("Email", userData!['email']),
                      buildDetailTile("Phone", userData!['phone']),
                      buildDetailTile("Address", userData!['address']),
                      buildDetailTile("Note", userData!['note']),
                      buildDetailTile("Website", userData!['website']),
                      // buildDetailTile("State", userData!['state']),
                    ],
                  ),
                ),
    );
  }

  Widget buildDetailTile(String title, String? value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value ?? "Not available"),
    );
  }
}
