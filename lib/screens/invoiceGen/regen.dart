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

Future<void> regen(
  BuildContext context,
  String invoiceNumber,
  String billto,
  String buyerAddress,
  String buyerEmail,
  String buyerPhone,
  Map<Item, int?> selectedItems,
) async {
  print('[REGEN] Starting invoice generation...');
  final pdf = pw.Document();

  print('[REGEN] Fetching user data...');
  final userData = await DatabaseService.instance.getUserById(1);
  print('[REGEN] User data retrieved: $userData');

  if (!context.mounted) {
    print('[REGEN] Context not mounted. Exiting.');
    return;
  }

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
    print('[REGEN] Company logo path: $companyLogoUrl');

    if (companyLogoUrl.isNotEmpty) {
      final file = File(companyLogoUrl);
      if (await file.exists()) {
        print('[REGEN] Company logo file exists, reading bytes...');
        final imageBytes = await file.readAsBytes();
        companyLogo = pw.MemoryImage(imageBytes);
        print('[REGEN] Company logo loaded.');
      } else {
        print('[REGEN] Company logo file not found.');
      }
    }

    double totalPrice = 0;
    print('[REGEN] Calculating total price...');
    selectedItems.forEach((item, quantity) {
      final safeQty = quantity ?? 1;
      totalPrice += item.price * safeQty;
      print('[REGEN] Item: ${item.name}, Qty: $safeQty, Price: ${item.price}');
    });
    print('[REGEN] Total price: $totalPrice');

    print('[REGEN] Adding PDF page...');
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
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(2),
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
                    final qty = entry.value ?? 1;
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
                  }).toList(),
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
    print('[REGEN] PDF page added successfully.');

    final output = await getTemporaryDirectory();
    final filePath = '${output.path}/invoicenew_$invoiceNumber.pdf';
    final file = File(filePath);
    print('[REGEN] Saving PDF to: $filePath');

    await file.writeAsBytes(await pdf.save());
    print('[REGEN] PDF saved successfully.');

    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
      print('[REGEN] Closed loading dialog.');
    }

    if (!context.mounted) {
      print('[REGEN] Context no longer mounted. Exiting before preview.');
      return;
    }

    print('[REGEN] Opening PDF preview...');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfPreviewPage(filePath: file.path)),
    );

    print('[REGEN] Sharing PDF...');
    await Share.shareXFiles([XFile(file.path)], text: 'Here is your invoice!');
    print('[REGEN] PDF shared successfully.');
  } catch (e, stackTrace) {
    print('[REGEN] ERROR during PDF generation: $e');
    print('[REGEN] STACKTRACE:\n$stackTrace');

    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }
}
