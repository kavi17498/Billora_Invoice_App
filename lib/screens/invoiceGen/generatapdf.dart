import 'dart:io';
import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/invoiceGen/pdfview.dart';
import 'package:invoiceapp/services/database_service.dart';
import 'package:invoiceapp/services/invoice_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:invoiceapp/services/item_service.dart';

Future<void> generateAndSharePdf(
  BuildContext context,
  String invoiceNumber,
  String billto,
  String buyerAddress,
  String buyerEmail,
  String buyerPhone,
  Map<Item, int> selectedItems,
) async {
  final pdf = pw.Document();
  final userData = await DatabaseService.instance.getUserById(1);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text("Generating PDF..."),
        ],
      ),
    ),
  );

  try {
    pw.MemoryImage? companyLogo;
    final companyLogoUrl = userData?['company_logo_url'] ?? '';

    if (companyLogoUrl.isNotEmpty) {
      final file = File(companyLogoUrl);
      if (await file.exists()) {
        final imageBytes = await file.readAsBytes();
        companyLogo = pw.MemoryImage(imageBytes);
      }
    }

    double totalPrice = 0;
    selectedItems.forEach((item, quantity) {
      totalPrice += item.price * quantity;
    });

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Invoice #$invoiceNumber',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('From: ${userData?['name'] ?? 'Company Name'}'),
              pw.Text('Email: ${userData?['email'] ?? ''}'),
              pw.Text('Phone: ${userData?['phone'] ?? ''}'),
              pw.Text('Address: ${userData?['address'] ?? ''}'),
              pw.Text('Website: ${userData?['website'] ?? ''}'),
              if (companyLogo != null)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 10),
                  child: pw.Image(companyLogo, width: 100, height: 100),
                ),
              pw.Divider(),
              pw.Text('Bill To: $billto', style: pw.TextStyle(fontSize: 16)),
              pw.Text('Address: $buyerAddress'),
              pw.Text('Email: $buyerEmail'),
              pw.Text('Phone: $buyerPhone'),
              pw.SizedBox(height: 20),
              pw.Text('Items:',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3), // Item Name
                  1: const pw.FlexColumnWidth(2), // Type
                  2: const pw.FlexColumnWidth(1), // Qty
                  3: const pw.FlexColumnWidth(2), // Price
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Item Name',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Type',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Qty',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Price (Rs)',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...selectedItems.entries.map((entry) {
                    final item = entry.key;
                    final qty = entry.value;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.name),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(item.type),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('$qty'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text('Rs. ${item.price.toStringAsFixed(2)}'),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total: Rs. ${totalPrice.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Text('Thank you for your business!',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice_$invoiceNumber.pdf');
    await file.writeAsBytes(await pdf.save());

    Navigator.pop(context); // Close loading dialog

    final invoiceId = await InvoiceService().saveInvoice(
      invoiceNumber: invoiceNumber,
      billTo: billto,
      address: buyerAddress,
      email: buyerEmail,
      phone: buyerPhone,
      totalPrice: totalPrice,
      selectedItems: selectedItems,
    );
    print("Invoice saved with ID: $invoiceId");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfPreviewPage(filePath: file.path)),
    );

    await Share.shareXFiles([XFile(file.path)], text: 'Here is your invoice!');
  } catch (e) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generating PDF: $e')),
    );
  }
}
