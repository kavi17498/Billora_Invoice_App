import 'dart:io';
import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/invoiceGen/pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

Future<void> generateAndSharePdf(BuildContext context, String clientName,
    String invoiceNumber, String description) async {
  final pdf = pw.Document();

  // Show loader dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Generating PDF..."),
          ],
        ),
      );
    },
  );

  try {
    // Generate PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Invoice #$invoiceNumber',
                style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text('Client: $clientName'),
            pw.Text('Description: $description'),
            pw.SizedBox(height: 20),
            pw.Text('Thank you for your business!'),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/invoice_$invoiceNumber.pdf");
    await file.writeAsBytes(await pdf.save());

    // Close loader
    Navigator.pop(context);

    // Navigate to PDF preview
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewPage(filePath: file.path),
      ),
    );

    // Optionally share
    await Share.shareXFiles([XFile(file.path)], text: 'Here is your invoice!');
  } catch (e) {
    Navigator.pop(context); // Close loader on error too
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generating PDF: $e')),
    );
  }
}
