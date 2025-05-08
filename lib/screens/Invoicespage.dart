import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/invoiceGen/generatapdf.dart';
import 'package:invoiceapp/screens/invoiceGen/regen.dart';
import 'package:invoiceapp/services/invoice_service.dart';
import 'package:invoiceapp/services/item_service.dart';
// where generateAndSharePdf is located

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({Key? key}) : super(key: key);

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  List<Map<String, dynamic>> invoices = [];

  @override
  void initState() {
    super.initState();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    final data = await InvoiceService().getAllInvoices();
    setState(() {
      invoices = data;
    });
  }

  Future<void> regenerateInvoice(Map<String, dynamic> invoice) async {
    // Fetch items and quantities from DB
    Map<Item, int> selectedItems =
        await InvoiceService().getItemsForInvoice(invoice['id']);

    await regen(
      context,
      invoice['invoice_number'],
      invoice['bill_to'],
      invoice['address'],
      invoice['email'],
      invoice['phone'],
      selectedItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: invoices.isEmpty
          ? const Center(child: Text("Crete a Client And Items First.."))
          : ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return ListTile(
                  title: Text("Invoice #${invoice['invoice_number']}"),
                  subtitle: Text("To: ${invoice['bill_to']}"),
                  trailing: Text("Rs. ${invoice['total'].toStringAsFixed(2)}"),
                  onTap: () => regenerateInvoice(invoice),
                );
              },
            ),
    );
  }
}
