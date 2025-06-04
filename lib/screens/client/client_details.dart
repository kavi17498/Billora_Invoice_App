import 'package:flutter/material.dart';
import 'package:invoiceapp/services/client_service.dart';

class ClientDetailsScreen extends StatefulWidget {
  final int clientId;

  const ClientDetailsScreen({super.key, required this.clientId});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClient();
  }

  Future<void> _fetchClient() async {
    final client = await ClientService.getClientById(widget.clientId);
    if (client != null) {
      _nameController.text = client['name'] ?? '';
      _emailController.text = client['email'] ?? '';
      _phoneController.text = client['phone'] ?? '';
      _addressController.text = client['address'] ?? '';
      _noteController.text = client['note'] ?? '';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveClient() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ClientService.updateClient(
        id: widget.clientId,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        note: _noteController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Client updated successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Client")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Name", _nameController, requiredField: true),
              _buildTextField("Email", _emailController),
              _buildTextField("Phone", _phoneController),
              _buildTextField("Address", _addressController),
              _buildTextField("Note", _noteController, maxLines: 3),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveClient,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool requiredField = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: requiredField
            ? (value) =>
                (value == null || value.isEmpty) ? "$label is required" : null
            : null,
      ),
    );
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
}
