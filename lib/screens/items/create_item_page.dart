import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/services/item_service.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key});

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
      Navigator.pushNamed(context, "/dashboard", arguments: 3);
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
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: TextStyle(
                      color:
                          secondaryColor), // Set the label text color to green
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            secondaryColor), // Set the line color when the field is not focused
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            secondaryColor), // Set the line color when the field is focused
                  ),
                ),
                style: TextStyle(
                    color: secondaryColor), // Set the input text color to green
                onSaved: (val) => _name = val ?? '',
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: TextStyle(color: secondaryColor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryColor),
                  ),
                ),
                style: TextStyle(color: secondaryColor),
                onSaved: (val) => _description = val ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Price",
                  labelStyle: TextStyle(color: secondaryColor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryColor),
                  ),
                ),
                style: TextStyle(color: secondaryColor),
                keyboardType: TextInputType.number,
                onSaved: (val) => _price = double.tryParse(val!) ?? 0,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Cost",
                  labelStyle: TextStyle(color: secondaryColor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryColor),
                  ),
                ),
                style: TextStyle(color: secondaryColor),
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
                decoration: InputDecoration(
                  labelText: "Type",
                  labelStyle: TextStyle(color: secondaryColor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryColor),
                  ),
                ),
              ),
              if (_type == 'good')
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Quantity",
                    labelStyle: TextStyle(color: secondaryColor),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: secondaryColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: secondaryColor),
                    ),
                  ),
                  style: TextStyle(color: secondaryColor),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => _quantity = int.tryParse(val!),
                ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  textStyle: TextStyle(color: backgroundColor),
                ),
                onPressed: _pickImage,
                icon: Icon(
                  Icons.image,
                  color: backgroundColor, // Set the icon color to white
                ),
                label: Text(
                  "Pick Image",
                  style: TextStyle(
                      color: backgroundColor), // Ensure the text color is white
                ),
              ),
              if (_imagePath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Image.file(File(_imagePath!), height: 100),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryColor, // Set the background color to primaryColor
                  textStyle: TextStyle(
                      color: backgroundColor), // Set the text color to white
                ),
                onPressed: _saveItem,
                child:
                    Text("Save Item", style: TextStyle(color: backgroundColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
