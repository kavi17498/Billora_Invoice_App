import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/invoiceGen/generatapdf.dart';

Future<void> showInvoiceDialog(BuildContext parentContext) async {
  final _formKey = GlobalKey<FormState>();

  String invoiceNumber = '';
  String billto = '';
  String buyeraddress = '';
  String buyeremail = '';
  String buyerphone = '';

  await showDialog(
    context: parentContext,
    builder: (context) {
      return AlertDialog(
        title: const Text('Create Invoice'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Invoice Number'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => invoiceNumber = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Buyer Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => billto = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Buyer Address'),
                  onSaved: (value) => buyeraddress = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Buyer Email'),
                  onSaved: (value) => buyeremail = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Buyer Phone'),
                  onSaved: (value) => buyerphone = value ?? '',
                ),
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
                Navigator.pop(context); // Close the dialog

                // ✅ Use parentContext here instead of dialog context
                await generateAndSharePdf(parentContext, invoiceNumber, billto,
                    buyeraddress, buyeremail, buyerphone);
              }
            },
            child: const Text('Generate PDF'),
          ),
        ],
      );
    },
  );
}
