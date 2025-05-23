import 'dart:io';
import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/invoiceGen/pdfview.dart';
import 'package:invoiceapp/screens/invoiceGen/regenpdf.dart';
import 'package:invoiceapp/services/database_service.dart';
import 'package:invoiceapp/services/item_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';

class RegenPage extends StatefulWidget {
  final String invoiceNumber;
  final String billTo;
  final String buyerAddress;
  final String buyerEmail;
  final String buyerPhone;
  final Map<Item, int?> selectedItems;

  const RegenPage({
    Key? key,
    required this.invoiceNumber,
    required this.billTo,
    required this.buyerAddress,
    required this.buyerEmail,
    required this.buyerPhone,
    required this.selectedItems,
  }) : super(key: key);

  @override
  _RegenPageState createState() => _RegenPageState();
}

class _RegenPageState extends State<RegenPage> {
  bool isGenerating = false; // Track whether the PDF is being generated

  Future<void> generatePdf() async {
    setState(() {
      isGenerating = true;
    });

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
      widget.selectedItems.forEach((item, quantity) {
        final safeQty = quantity ?? 1; // Handle null quantities
        totalPrice += item.price * safeQty;
      });

      // Create PDF content
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Invoice #${widget.invoiceNumber}',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('From: ${userData['name'] ?? 'Company Name'}'),
                pw.Text('Email: ${userData['email'] ?? ''}'),
                pw.Text('Phone: ${userData['phone'] ?? ''}'),
                pw.Text('Address: ${userData['address'] ?? ''}'),
                if (companyLogo != null)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 10),
                    child: pw.Image(companyLogo, width: 100, height: 100),
                  ),
                pw.Divider(),
                pw.Text('Bill To: ${widget.billTo}'),
                pw.Text('Address: ${widget.buyerAddress}'),
                pw.Text('Email: ${widget.buyerEmail}'),
                pw.Text('Phone: ${widget.buyerPhone}'),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: widget.selectedItems.entries.map((entry) {
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
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Total: Rs. ${totalPrice.toStringAsFixed(2)}'),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final filePath = '${output.path}/invoicenew_${widget.invoiceNumber}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      // Navigate to the PDF preview page
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Regenpdf(filePath: file.path)),
        );
      }
    } catch (e) {
      print('[REGEN] ERROR during PDF generation: $e');
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

  @override
  Widget build(BuildContext context) {
    // Start PDF generation when page loads.
    generatePdf();

    return Scaffold(
      appBar: AppBar(title: Text('Generating Invoice PDF')),
      body: Center(
        child: isGenerating
            ? CircularProgressIndicator()
            : Container(), // No text, simply a loading spinner until PDF generation completes.
      ),
    );
  }
}
