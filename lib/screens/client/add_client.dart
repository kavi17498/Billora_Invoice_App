import 'package:flutter/material.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/services/client_service.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  Future<void> _saveClient() async {
    if (_formKey.currentState!.validate()) {
      await ClientService.insertClient(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        note: _noteController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client added successfully!')),
      );

      Navigator.pushNamed(
        context,
        "/dashboard",
        arguments: 2,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Name', isRequired: true),
              _buildEmailField(),
              _buildPhoneField(),
              _buildTextField(_addressController, 'Address'),
              _buildTextField(_noteController, 'Note', maxLines: 3),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryColor, // Set button background to blue
                  textStyle: TextStyle(color: Colors.white), // Text color white
                ),
                icon: const Icon(Icons.save,
                    color: Colors.white), // Icon color white
                label: Text(
                  'Save Client',
                  style: TextStyle(color: backgroundColor),
                ),
                onPressed: _saveClient,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: secondaryColor), // Label text color blue
          border: OutlineInputBorder(
            borderSide: BorderSide(color: secondaryColor), // Border color blue
          ),
        ),
        style: TextStyle(color: secondaryColor), // Input text color blue
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  // Email validation using regex
  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(color: secondaryColor),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: secondaryColor),
          ),
        ),
        style: TextStyle(color: secondaryColor),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email is required';
          }
          // Regex pattern for email validation
          final emailRegex =
              RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Enter a valid email address';
          }
          return null;
        },
      ),
    );
  }

  // Phone number validation: ensure numeric input
  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: 'Phone',
          labelStyle: TextStyle(color: secondaryColor),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: secondaryColor),
          ),
        ),
        style: TextStyle(color: secondaryColor),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Phone number is required';
          }
          // Ensure the phone number only contains digits
          final phoneRegex = RegExp(r'^\d+$');
          if (!phoneRegex.hasMatch(value)) {
            return 'Enter a valid phone number';
          }
          return null;
        },
      ),
    );
  }
}
