import 'dart:io';
import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/invoiceGen/pdfview.dart';
import 'package:invoiceapp/services/database_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';

Future<void> generateAndSharePdf(
  BuildContext context,
  String invoiceNumber,
  String billto,
  String buyerAddress,
  String buyerEmail,
  String buyerPhone,
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
    // Fetch the logo
    pw.MemoryImage? companyLogo;
    final companyLogoUrl = userData?['company_logo_url'] ?? '';

    if (companyLogoUrl.isNotEmpty) {
      final file = File(companyLogoUrl);
      if (await file.exists()) {
        final imageBytes = await file.readAsBytes();
        companyLogo = pw.MemoryImage(imageBytes);
      } else {}
    }

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
              pw.Divider(),
              pw.Text('From: ${userData?['name'] ?? 'Company Name'}'),
              pw.Text('Email: ${userData?['email'] ?? ''}'),
              pw.Text('Phone: ${userData?['phone'] ?? ''}'),
              pw.Text('Address: ${userData?['address'] ?? ''}'),
              pw.Text('Website: ${userData?['website'] ?? ''}'),
              if (companyLogo != null)
                pw.Image(companyLogo, width: 100, height: 100),
              pw.SizedBox(height: 20),
              pw.Text('Bill To: $billto', style: pw.TextStyle(fontSize: 16)),
              pw.Text('Address: $buyerAddress'),
              pw.Text('Email: $buyerEmail'),
              pw.Text('Phone: $buyerPhone'),
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

    Navigator.pop(context); // close loading

    // Navigate to PDF preview screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfPreviewPage(filePath: file.path)),
    );

    // Optional sharing
    await Share.shareXFiles([XFile(file.path)], text: 'Here is your invoice!');
  } catch (e) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generating PDF: $e')),
    );
  }
}
