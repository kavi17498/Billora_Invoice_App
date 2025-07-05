import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/invoiceGen/generatapdf.dart';
import 'package:invoiceapp/services/item_service.dart';
import 'package:invoiceapp/services/client_service.dart';
import 'package:invoiceapp/services/currency_service.dart';
import 'dart:math';

Future<void> showInvoiceDialog(BuildContext parentContext) async {
  final formKey = GlobalKey<FormState>();

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
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: invoiceNumber,
                      decoration:
                          const InputDecoration(labelText: 'Invoice Number'),
                      onSaved: (value) => invoiceNumber = value!,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Invoice number cannot be empty';
                        }
                        return null;
                      },
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
                            subtitle: FutureBuilder<String>(
                              future: CurrencyService
                                  .formatAmountWithCurrentCurrency(item.price),
                              builder: (context, snapshot) {
                                return Text(snapshot.data ??
                                    '\$${item.price.toStringAsFixed(2)}');
                              },
                            ),
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
                          if (isSelected)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Quantity sold for ${item.name}',
                                  hintText: 'How many did you sell?',
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
                    }),
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
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();

                    // No inventory management - just proceed with invoice creation
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
