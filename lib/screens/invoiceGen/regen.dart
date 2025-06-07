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
    super.key,
    required this.invoiceNumber,
    required this.billTo,
    required this.buyerAddress,
    required this.buyerEmail,
    required this.buyerPhone,
    required this.selectedItems,
  });

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

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header Row: Logo and Company Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (companyLogo != null)
                      pw.Image(companyLogo, width: 80, height: 80),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('${userData['name'] ?? 'Company Name'}',
                            style: pw.TextStyle(
                                fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Email: ${userData['email'] ?? ''}'),
                        pw.Text('Phone: ${userData['phone'] ?? ''}'),
                        pw.Text('Address: ${userData['address'] ?? ''}',
                            textAlign: pw.TextAlign.right),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Invoice Title and Number
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('INVOICE',
                        style: pw.TextStyle(
                            fontSize: 26,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey900)),
                    pw.Text('Invoice #${widget.invoiceNumber}',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800)),
                  ],
                ),

                pw.SizedBox(height: 20),

                // BILL TO Section
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILL TO',
                          style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blueGrey700)),
                      pw.SizedBox(height: 6),
                      pw.Text(widget.billTo),
                      pw.Text('Address: ${widget.buyerAddress}'),
                      pw.Text('Email: ${widget.buyerEmail}'),
                      pw.Text('Phone: ${widget.buyerPhone}'),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Items Table Title
                pw.Text('Items',
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey800)),
                pw.SizedBox(height: 10),

                // Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Item Name',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blueGrey700)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Qty',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blueGrey700)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Price (Rs)',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blueGrey700)),
                        ),
                      ],
                    ),
                    ...widget.selectedItems.entries.map((entry) {
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
                  ],
                ),

                // Total
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blueGrey100,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                          'Total: Rs. ${totalPrice.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blueGrey800)),
                    ),
                  ],
                ),

                // Footer
                pw.SizedBox(height: 30),
                pw.Divider(),
                pw.Center(
                  child: pw.Text('Thank you for your business!',
                      style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey700)),
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
      body: Center(
        child: isGenerating
            ? CircularProgressIndicator()
            : Container(), // No text, simply a loading spinner until PDF generation completes.
      ),
    );
  }
}
