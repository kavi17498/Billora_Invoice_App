import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/invoiceGen/generatapdf.dart'; // RegenPage import
import 'package:invoiceapp/screens/invoiceGen/regen.dart';
import 'package:invoiceapp/services/invoice_service.dart';
import 'package:invoiceapp/services/item_service.dart';

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

  // This is where we call RegenPage to handle the PDF generation process.
  Future<void> regenerateInvoice(Map<String, dynamic> invoice) async {
    // Fetch items and quantities from DB
    Map<Item, int> selectedItems =
        await InvoiceService().getItemsForInvoice(invoice['id']);

    // Navigate to RegenPage and pass all required parameters for PDF generation.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegenPage(
          invoiceNumber: invoice['invoice_number'],
          billTo: invoice['bill_to'],
          buyerAddress: invoice['address'],
          buyerEmail: invoice['email'],
          buyerPhone: invoice['phone'],
          selectedItems: selectedItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: invoices.isEmpty
          ? const Center(child: Text("Create a Client And Items First.."))
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
