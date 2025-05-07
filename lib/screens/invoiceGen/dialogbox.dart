import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/invoiceGen/generatapdf.dart';
import 'package:invoiceapp/services/item_service.dart';
import 'package:invoiceapp/services/client_service.dart';
import 'dart:math';

Future<void> showInvoiceDialog(BuildContext parentContext) async {
  final _formKey = GlobalKey<FormState>();

  String invoiceNumber = 'INV-${Random().nextInt(100000)}'; // Auto-generated
  int? selectedClientId;
  String billto = '';
  String buyeraddress = '';
  String buyeremail = '';
  String buyerphone = '';

  List<Item> allItems = await ItemService.getAllItems();
  List<Map<String, dynamic>> allClients = await ClientService.getAllClients();
  Map<Item, int> selectedItemsWithQuantity = {};

  await showDialog(
    context: parentContext,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create Invoice'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: invoiceNumber,
                      decoration:
                          const InputDecoration(labelText: 'Invoice Number'),
                      readOnly: true,
                      onSaved: (value) => invoiceNumber = value!,
                    ),
                    DropdownButtonFormField<int>(
                      decoration:
                          const InputDecoration(labelText: 'Select Client'),
                      items: allClients.map((client) {
                        return DropdownMenuItem<int>(
                          value: client['id'],
                          child: Text(client['name']),
                        );
                      }).toList(),
                      onChanged: (clientId) async {
                        setState(() {
                          selectedClientId = clientId;
                        });
                        final selectedClient = allClients
                            .firstWhere((client) => client['id'] == clientId);
                        billto = selectedClient['name'];
                        buyeremail = selectedClient['email'] ?? '';
                        buyeraddress = selectedClient['address'] ?? '';
                        buyerphone = selectedClient['phone'] ?? '';
                      },
                      validator: (value) =>
                          value == null ? 'Please select a client' : null,
                    ),
                    const SizedBox(height: 20),
                    const Text("Select Items:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...allItems.map((item) {
                      final isSelected =
                          selectedItemsWithQuantity.containsKey(item);
                      return Column(
                        children: [
                          CheckboxListTile(
                            value: isSelected,
                            title: Text(item.name),
                            subtitle: Text(item.type == 'good'
                                ? 'Available: ${item.quantity}'
                                : 'Service'),
                            onChanged: (selected) {
                              setState(() {
                                if (selected!) {
                                  selectedItemsWithQuantity[item] = 1;
                                } else {
                                  selectedItemsWithQuantity.remove(item);
                                }
                              });
                            },
                          ),
                          if (isSelected && item.type == 'good')
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Quantity for ${item.name}',
                                ),
                                keyboardType: TextInputType.number,
                                initialValue:
                                    selectedItemsWithQuantity[item].toString(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter quantity';
                                  }
                                  final qty = int.tryParse(value);
                                  if (qty == null || qty <= 0) {
                                    return 'Invalid quantity';
                                  }
                                  if (item.quantity != null &&
                                      qty > item.quantity!) {
                                    return 'Exceeds available quantity';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  final qty = int.tryParse(value);
                                  if (qty != null && qty > 0) {
                                    selectedItemsWithQuantity[item] = qty;
                                  }
                                },
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    for (var entry in selectedItemsWithQuantity.entries) {
                      final item = entry.key;
                      final sellQty = entry.value;

                      if (item.type == 'good' && item.quantity != null) {
                        item.quantity = item.quantity! - sellQty;
                        await ItemService.updateItem(item);
                      }
                    }

                    Navigator.pop(context);

                    await generateAndSharePdf(
                      parentContext,
                      invoiceNumber,
                      billto,
                      buyeraddress,
                      buyeremail,
                      buyerphone,
                      selectedItemsWithQuantity,
                    );
                  }
                },
                child: const Text('Generate PDF'),
              ),
            ],
          );
        },
      );
    },
  );
}
