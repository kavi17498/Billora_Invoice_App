import 'dart:io';
import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/invoiceGen/pdfview.dart';
import 'package:invoiceapp/services/database_service.dart';
import 'package:invoiceapp/services/invoice_service.dart';
import 'package:invoiceapp/services/template_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:invoiceapp/services/item_service.dart';
import 'package:invoiceapp/models/invoice_template.dart';

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
  final template = await TemplateService.getSelectedTemplate();

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
    double totalDiscount = 0;
    selectedItems.forEach((item, quantity) {
      double itemSubtotal = item.price * quantity;
      double itemDiscount = 0;

      // Calculate discount for this item
      if (item.discountPercentage > 0) {
        itemDiscount = itemSubtotal * (item.discountPercentage / 100);
      } else if (item.discountAmount > 0) {
        itemDiscount = item.discountAmount * quantity;
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
              _buildInvoiceTitle(template, invoiceNumber),
              pw.SizedBox(height: 20),
              _buildBillToSection(
                  template, billto, buyerAddress, buyerEmail, buyerPhone),
              pw.SizedBox(height: 20),
              _buildItemsSection(template, selectedItems),
              pw.SizedBox(height: 20),
              _buildTotal(template, totalPrice, totalDiscount),
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

// Helper functions for building PDF sections with template support

pw.Widget _buildHeader(InvoiceTemplate template, Map<String, dynamic>? userData,
    pw.MemoryImage? companyLogo) {
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

pw.Widget _buildItemsSection(
    InvoiceTemplate template, Map<Item, int> selectedItems) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('Items',
          style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: template.colors.primary)),
      pw.SizedBox(height: 10),
      _buildItemsTable(template, selectedItems),
    ],
  );
}

pw.Widget _buildItemsTable(
    InvoiceTemplate template, Map<Item, int> selectedItems) {
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
            child: pw.Text('Price (Rs)',
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
            child: pw.Text('Final Price (Rs)',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: primaryColor)),
          ),
        ],
      ),
      ...selectedItems.entries.map((entry) {
        final item = entry.key;
        final qty = entry.value;
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
          discountText = 'Rs. ${item.discountAmount.toStringAsFixed(2)}';
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
              child: pw.Text(item.name, style: pw.TextStyle(color: textColor)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(item.type, style: pw.TextStyle(color: textColor)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('$qty', style: pw.TextStyle(color: textColor)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Rs. ${item.price.toStringAsFixed(2)}',
                  style: pw.TextStyle(color: textColor)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child:
                  pw.Text(discountText, style: pw.TextStyle(color: textColor)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Rs. ${finalPrice.toStringAsFixed(2)}',
                  style: pw.TextStyle(color: textColor)),
            ),
          ],
        );
      }).toList(),
    ],
  );
}

pw.Widget _buildTotal(
    InvoiceTemplate template, double totalPrice, double totalDiscount) {
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
              'Total Discount: Rs. ${totalDiscount.toStringAsFixed(2)}',
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
        child: pw.Text('Total: Rs. ${totalPrice.toStringAsFixed(2)}',
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
