import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoiceapp/services/item_service.dart';

class EditItemPage extends StatefulWidget {
  final int itemId;
  const EditItemPage({Key? key, required this.itemId}) : super(key: key);

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late TextEditingController costController;
  late TextEditingController quantityController;

  String imagePath = '';
  String type = 'good';
  bool isLoading = true;
  Item? item;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    item = await ItemService.getItemById(widget.itemId);
    if (item != null) {
      nameController = TextEditingController(text: item!.name);
      descController = TextEditingController(text: item!.description);
      priceController = TextEditingController(text: item!.price.toString());
      costController = TextEditingController(text: item!.cost.toString());
      quantityController = TextEditingController(
        text: item!.quantity?.toString() ?? '',
      );
      imagePath = item!.imagePath;
      type = item!.type;
    }
    setState(() => isLoading = false);
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate() && item != null) {
      final updated = Item(
        id: item!.id,
        name: nameController.text,
        description: descController.text,
        price: double.parse(priceController.text),
        cost: double.parse(costController.text),
        imagePath: imagePath,
        type: type,
        quantity: type == 'good' ? int.tryParse(quantityController.text) : null,
      );
      await ItemService.updateItem(updated);
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imagePath = picked.path);
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      await ItemService.deleteItem(item!.id!);
      Navigator.pop(context); // Go back after deletion
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Item")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (imagePath.isNotEmpty)
                Image.file(File(imagePath), height: 150, fit: BoxFit.cover),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Change Image"),
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) => val!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: costController,
                decoration: const InputDecoration(labelText: 'Cost'),
                keyboardType: TextInputType.number,
              ),
              if (type == 'good')
                TextFormField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text("Save Changes"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _deleteItem,
                child: const Text("Delete Item"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
