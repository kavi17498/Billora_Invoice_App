import 'dart:io';
import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/invoiceGen/regenpdf.dart';
import 'package:invoiceapp/services/database_service.dart';
import 'package:invoiceapp/services/item_service.dart';
import 'package:invoiceapp/services/template_service.dart';
import 'package:invoiceapp/services/currency_service.dart';
import 'package:invoiceapp/models/invoice_template.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

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
  bool hasStarted = false; // Prevent multiple calls to generatePdf
  bool isCompleted = false; // Track if PDF generation is completed

  @override
  void initState() {
    super.initState();
    // Generate PDF only once when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasStarted && !isCompleted) {
        hasStarted = true;
        generatePdf();
      }
    });
  }

  Future<void> generatePdf() async {
    setState(() {
      isGenerating = true;
    });

    print('[REGEN] Starting invoice generation.');
    final pdf = pw.Document();

    print('[REGEN] Fetching user data and template.');
    final userData = await DatabaseService.instance.getUserById(1);
    final template = await TemplateService.getSelectedTemplate();
    print('[REGEN] Fetched user data: $userData');
    print('[REGEN] Using template: ${template.name}');

    if (userData == null) {
      print('[REGEN] User data is missing. Exiting.');
      setState(() {
        isGenerating = false;
      });
      return;
    }

    if (!context.mounted) {
      print('[REGEN] Context not mounted. Exiting.');
      setState(() {
        isGenerating = false;
      });
      return;
    }

    try {
      // Get current currency
      final currency = await CurrencyService.getCurrentCurrency();

      // Handle logo loading
      pw.MemoryImage? companyLogo;
      final companyLogoUrl = userData['company_logo_url'];
      print('[REGEN] Company logo path: $companyLogoUrl');

      if (companyLogoUrl != null && companyLogoUrl.isNotEmpty) {
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
      double totalDiscount = 0;
      widget.selectedItems.forEach((item, quantity) {
        final safeQty = quantity ?? 1; // Handle null quantities
        double itemSubtotal = item.price * safeQty;
        double itemDiscount = 0;

        // Calculate discount for this item
        if (item.discountPercentage > 0) {
          itemDiscount = itemSubtotal * (item.discountPercentage / 100);
        } else if (item.discountAmount > 0) {
          itemDiscount = item.discountAmount * safeQty;
        }

        totalDiscount += itemDiscount;
        totalPrice += itemSubtotal - itemDiscount;
      });

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(template, userData, companyLogo),
                pw.SizedBox(height: 20),
                _buildInvoiceTitle(template, widget.invoiceNumber),
                pw.SizedBox(height: 20),
                _buildBillToSection(template, widget.billTo,
                    widget.buyerAddress, widget.buyerEmail, widget.buyerPhone),
                pw.SizedBox(height: 20),
                _buildItemsSection(template, widget.selectedItems, currency),
                pw.SizedBox(height: 20),
                _buildTotal(template, totalPrice, totalDiscount, currency),
                pw.SizedBox(height: 15),
                _buildPaymentInstructions(template, userData),
                pw.Divider(color: template.colors.border),
                if (template.layout.showFooter) _buildFooter(template),
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
        setState(() {
          isGenerating = false;
          isCompleted = true;
        });
      }

      // Navigate to the PDF preview page and handle return
      if (context.mounted) {
        try {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Regenpdf(filePath: file.path)),
          );

          // When returning from PDF viewer, go back to the previous screen
          if (context.mounted) {
            Navigator.pop(context);
          }
        } catch (e) {
          print('[REGEN] Navigation error: $e');
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      print('[REGEN] ERROR during PDF generation: $e');
      setState(() {
        isGenerating = false;
        isCompleted = true;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
        // Navigate back on error
        Navigator.pop(context);
      }
    }
  }

  // Helper functions for building PDF sections with template support
  pw.Widget _buildHeader(InvoiceTemplate template,
      Map<String, dynamic>? userData, pw.MemoryImage? companyLogo) {
    switch (template.layout.headerStyle) {
      case 'minimal':
        return _buildMinimalHeader(template, userData);
      case 'centered':
        return _buildCenteredHeader(template, userData, companyLogo);
      case 'split':
      default:
        return _buildSplitHeader(template, userData, companyLogo);
    }
  }

  pw.Widget _buildMinimalHeader(
      InvoiceTemplate template, Map<String, dynamic>? userData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('${userData?['name'] ?? 'Company Name'}',
            style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: template.colors.text)),
        pw.Text('Email: ${userData?['email'] ?? ''}',
            style: pw.TextStyle(color: template.colors.text)),
        pw.Text('Phone: ${userData?['phone'] ?? ''}',
            style: pw.TextStyle(color: template.colors.text)),
        pw.Text('Address: ${userData?['address'] ?? ''}',
            style: pw.TextStyle(color: template.colors.text)),
        pw.Text('Website: ${userData?['website'] ?? ''}',
            style: pw.TextStyle(color: template.colors.text)),
      ],
    );
  }

  pw.Widget _buildCenteredHeader(InvoiceTemplate template,
      Map<String, dynamic>? userData, pw.MemoryImage? companyLogo) {
    return pw.Column(
      children: [
        if (template.layout.showLogo && companyLogo != null)
          pw.Image(companyLogo, width: 80, height: 80),
        pw.SizedBox(height: 10),
        pw.Text('${userData?['name'] ?? 'Company Name'}',
            style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: template.colors.text)),
        pw.Text('Email: ${userData?['email'] ?? ''}',
            style: pw.TextStyle(color: template.colors.text)),
        pw.Text('Phone: ${userData?['phone'] ?? ''}',
            style: pw.TextStyle(color: template.colors.text)),
        pw.Text('Address: ${userData?['address'] ?? ''}',
            style: pw.TextStyle(color: template.colors.text)),
        pw.Text('Website: ${userData?['website'] ?? ''}',
            style: pw.TextStyle(color: template.colors.text)),
      ],
    );
  }

  pw.Widget _buildSplitHeader(InvoiceTemplate template,
      Map<String, dynamic>? userData, pw.MemoryImage? companyLogo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (template.layout.showLogo && companyLogo != null)
          pw.Image(companyLogo, width: 80, height: 80),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('${userData?['name'] ?? 'Company Name'}',
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: template.colors.text)),
            pw.Text('Email: ${userData?['email'] ?? ''}',
                style: pw.TextStyle(color: template.colors.text)),
            pw.Text('Phone: ${userData?['phone'] ?? ''}',
                style: pw.TextStyle(color: template.colors.text)),
            pw.Text('Address: ${userData?['address'] ?? ''}',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(color: template.colors.text)),
            pw.Text('Website: ${userData?['website'] ?? ''}',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(color: template.colors.text)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildInvoiceTitle(InvoiceTemplate template, String invoiceNumber) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('INVOICE',
            style: pw.TextStyle(
                fontSize: 26,
                fontWeight: pw.FontWeight.bold,
                color: template.colors.primary)),
        pw.Text('Invoice #$invoiceNumber',
            style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: template.colors.text)),
      ],
    );
  }

  pw.Widget _buildBillToSection(InvoiceTemplate template, String billto,
      String buyerAddress, String buyerEmail, String buyerPhone) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: template.colors.border),
        borderRadius: pw.BorderRadius.circular(4),
        color: template.colors.secondary,
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('BILL TO',
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: template.colors.primary)),
          pw.SizedBox(height: 6),
          pw.Text(billto, style: pw.TextStyle(color: template.colors.text)),
          pw.Text('Address: $buyerAddress',
              style: pw.TextStyle(color: template.colors.text)),
          pw.Text('Email: $buyerEmail',
              style: pw.TextStyle(color: template.colors.text)),
          pw.Text('Phone: $buyerPhone',
              style: pw.TextStyle(color: template.colors.text)),
        ],
      ),
    );
  }

  pw.Widget _buildItemsSection(InvoiceTemplate template,
      Map<Item, int?> selectedItems, Currency currency) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Items',
            style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: template.colors.primary)),
        pw.SizedBox(height: 10),
        _buildItemsTable(template, selectedItems, currency),
      ],
    );
  }

  pw.Widget _buildItemsTable(InvoiceTemplate template,
      Map<Item, int?> selectedItems, Currency currency) {
    final borderColor = template.colors.border;
    final headerColor = template.colors.secondary;
    final textColor = template.colors.text;
    final primaryColor = template.colors.primary;

    return pw.Table(
      border: template.layout.tableStyle == 'bordered'
          ? pw.TableBorder.all(color: borderColor)
          : null,
      columnWidths: {
        0: const pw.FlexColumnWidth(3), // Item Name
        1: const pw.FlexColumnWidth(2), // Type
        2: const pw.FlexColumnWidth(1), // Qty
        3: const pw.FlexColumnWidth(2), // Price
        4: const pw.FlexColumnWidth(2), // Discount
        5: const pw.FlexColumnWidth(2), // Final Price
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: template.layout.tableStyle == 'simple' ? null : headerColor,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Item Name',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: primaryColor)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Type',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: primaryColor)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Qty',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: primaryColor)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Price (${currency.symbol})',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: primaryColor)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Discount',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: primaryColor)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Final Price (${currency.symbol})',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: primaryColor)),
            ),
          ],
        ),
        ...selectedItems.entries.map((entry) {
          final item = entry.key;
          final qty = entry.value ?? 1;
          final index = selectedItems.keys.toList().indexOf(item);
          final isEven = index % 2 == 0;

          // Calculate discount for this item
          double itemSubtotal = item.price * qty;
          double itemDiscount = 0;
          String discountText = '-';

          if (item.discountPercentage > 0) {
            itemDiscount = itemSubtotal * (item.discountPercentage / 100);
            discountText = '${item.discountPercentage.toStringAsFixed(1)}%';
          } else if (item.discountAmount > 0) {
            itemDiscount = item.discountAmount * qty;
            discountText =
                '${currency.symbol} ${item.discountAmount.toStringAsFixed(2)}';
          }

          double finalPrice = itemSubtotal - itemDiscount;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: template.layout.tableStyle == 'striped' && !isEven
                  ? headerColor
                  : null,
            ),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child:
                    pw.Text(item.name, style: pw.TextStyle(color: textColor)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child:
                    pw.Text(item.type, style: pw.TextStyle(color: textColor)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('$qty', style: pw.TextStyle(color: textColor)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                    '${currency.symbol} ${item.price.toStringAsFixed(2)}',
                    style: pw.TextStyle(color: textColor)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(discountText,
                    style: pw.TextStyle(color: textColor)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                    '${currency.symbol} ${finalPrice.toStringAsFixed(2)}',
                    style: pw.TextStyle(color: textColor)),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildTotal(InvoiceTemplate template, double totalPrice,
      double totalDiscount, Currency currency) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        if (totalDiscount > 0) ...[
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            margin: const pw.EdgeInsets.only(bottom: 4),
            decoration: pw.BoxDecoration(
              color: template.colors.background,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: template.colors.border),
            ),
            child: pw.Text(
                'Total Discount: ${currency.symbol} ${totalDiscount.toStringAsFixed(2)}',
                style: pw.TextStyle(
                    fontSize: 12,
                    color: template.colors.text,
                    fontWeight: pw.FontWeight.normal)),
          ),
        ],
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: template.colors.secondary,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
              'Total: ${currency.symbol} ${totalPrice.toStringAsFixed(2)}',
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: template.colors.primary)),
        ),
      ],
    );
  }

  pw.Widget _buildPaymentInstructions(
      InvoiceTemplate template, Map<String, dynamic>? userData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Payment Instructions: ',
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: template.colors.text)),
        pw.SizedBox(height: 5),
        pw.Text('${userData?['note'] ?? ''}',
            style: pw.TextStyle(color: template.colors.text)),
      ],
    );
  }

  pw.Widget _buildFooter(InvoiceTemplate template) {
    return pw.Center(
      child: pw.Text(template.layout.footerText,
          style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: template.colors.text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isGenerating, // Prevent going back while generating
      child: Scaffold(
        body: Center(
          child: isGenerating
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating PDF...', style: TextStyle(fontSize: 16)),
                  ],
                )
              : isCompleted
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 48),
                        SizedBox(height: 16),
                        Text('PDF Generated Successfully!',
                            style: TextStyle(fontSize: 16)),
                      ],
                    )
                  : Container(), // Empty container when not generating
        ),
      ),
    );
  }
}
