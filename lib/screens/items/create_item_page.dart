import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoiceapp/services/item_service.dart';
import 'package:path/path.dart' as p;

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({Key? key}) : super(key: key);

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  String _name = '';
  String _description = '';
  double _price = 0;
  double _cost = 0;
  String _type = 'service';
  int? _quantity;
  String? _imagePath;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final item = Item(
        name: _name,
        description: _description,
        price: _price,
        cost: _cost,
        imagePath: _imagePath ?? '',
        type: _type,
        quantity: _type == 'good' ? _quantity : null,
      );
      await ItemService.insertItem(item);
      Navigator.pushNamed(context, "/items");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Item")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Name"),
                onSaved: (val) => _name = val ?? '',
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Description"),
                onSaved: (val) => _description = val ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                onSaved: (val) => _price = double.tryParse(val!) ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Cost"),
                keyboardType: TextInputType.number,
                onSaved: (val) => _cost = double.tryParse(val!) ?? 0,
              ),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'service', child: Text('Service')),
                  DropdownMenuItem(value: 'good', child: Text('Good')),
                ],
                onChanged: (val) => setState(() => _type = val!),
                decoration: const InputDecoration(labelText: "Type"),
              ),
              if (_type == 'good')
                TextFormField(
                  decoration: const InputDecoration(labelText: "Quantity"),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => _quantity = int.tryParse(val!),
                ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Pick Image"),
              ),
              if (_imagePath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Image.file(File(_imagePath!), height: 100),
                ),
              ElevatedButton(
                onPressed: _saveItem,
                child: const Text("Save Item"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
