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
  print('[REGEN] Starting invoice generation.');
  final pdf = pw.Document();

  print('[REGEN] Fetching user data.');
  final userData = await DatabaseService.instance.getUserById(1);
  print('[REGEN] Fetched user data: $userData');

  if (userData == null || !userData.containsKey('company_logo_url')) {
    print(userData);
    print('[REGEN] User data or company logo is missing. Exiting.');
    return;
  }

  if (!context.mounted) {
    print('[REGEN] Context not mounted. Exiting.');
    return;
  }

  // Show loading dialog
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
    // Handle logo loading
    pw.MemoryImage? companyLogo;
    final companyLogoUrl = userData['company_logo_url'];
    print('[REGEN] Company logo path: $companyLogoUrl');

    if (companyLogoUrl.isNotEmpty) {
      final file = File(companyLogoUrl);
      print('[REGEN] File exists: ${await file.exists()}');
      if (await file.exists()) {
        print('[REGEN] Company logo file exists, reading bytes...');
        final imageBytes = await file.readAsBytes();
        companyLogo = pw.MemoryImage(imageBytes);
      } else {
        print('[REGEN] Company logo file not found.');
      }
    }

    // Calculate total price and handle null quantities
    double totalPrice = 0;
    selectedItems.forEach((item, quantity) {
      final safeQty = quantity ?? 1; // Handle null quantities
      if (quantity == null) {
        print(
            '[REGEN] Warning: Null quantity found for item ${item.name}, defaulting to 1');
      }
      print(
          '[REGEN] Item: ${item.name}, Quantity: $safeQty, Price: ${item.price}');
      totalPrice += item.price * safeQty;
    });
    print('[REGEN] Total price: $totalPrice');

    // Create PDF content
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          print('[REGEN] Generating PDF content...');
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Invoice #$invoiceNumber',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('From: ${userData['name'] ?? 'Company Name'}'),
              pw.Text('Email: ${userData['email'] ?? ''}'),
              pw.Text('Phone: ${userData['phone'] ?? ''}'),
              pw.Text('Address: ${userData['address'] ?? ''}'),
              pw.Text('Website: ${userData['website'] ?? ''}'),
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
                children: selectedItems.entries.map((entry) {
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
                        child: pw.Text('Rs. ${item.price.toStringAsFixed(2)}'),
                      ),
                    ],
                  );
                }).toList(),
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
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    print('[REGEN] Temporary directory: ${output.path}');
    final filePath = '${output.path}/invoicenew_$invoiceNumber.pdf';
    print('[REGEN] Saving PDF to: $filePath');
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
    }

    // Check if context is mounted before pushing a new route
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PdfPreviewPage(filePath: file.path)),
      );
    }

    // Share the PDF
    await Share.shareXFiles([XFile(file.path)], text: 'Here is your invoice!');
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
