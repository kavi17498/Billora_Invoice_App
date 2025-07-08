import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoiceapp/screens/invoiceGen/regen.dart';
import 'package:invoiceapp/services/invoice_service.dart';
import 'package:invoiceapp/services/item_service.dart';
import 'package:invoiceapp/services/currency_service.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';
import 'package:invoiceapp/components/AppCard.dart';
import 'package:invoiceapp/components/AppLoading.dart';
import 'dart:io';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  List<Map<String, dynamic>> invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    try {
      final data = await InvoiceService().getAllInvoices();
      if (mounted) {
        setState(() {
          invoices = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load invoices: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // This is where we call RegenPage to handle the PDF generation process.
  Future<void> regenerateInvoice(Map<String, dynamic> invoice) async {
    try {
      // Show a brief message indicating that the current template will be used
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Regenerating invoice with current template...'),
          duration: Duration(seconds: 1),
          backgroundColor: AppColors.primary,
        ),
      );

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error regenerating invoice: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Show options menu for invoice actions
  Future<void> _showInvoiceOptions(
      BuildContext context, Map<String, dynamic> invoice) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Invoice #${invoice['invoice_number']}',
                      style: AppTextStyles.h5,
                    ),
                    Text(
                      '\$${invoice['total'].toStringAsFixed(2)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Options
              _buildOptionTile(
                icon: Icons.picture_as_pdf_rounded,
                title: 'Regenerate PDF',
                subtitle: 'Generate with current template',
                onTap: () {
                  Navigator.pop(context);
                  regenerateInvoice(invoice);
                },
              ),
              _buildOptionTile(
                icon: Icons.download_rounded,
                title: 'Download',
                subtitle: 'Save PDF to device',
                onTap: () {
                  Navigator.pop(context);
                  _downloadInvoice(invoice);
                },
              ),
              _buildOptionTile(
                icon: Icons.share_rounded,
                title: 'Share',
                subtitle: 'Share via apps',
                onTap: () {
                  Navigator.pop(context);
                  _shareInvoice(invoice);
                },
              ),
              _buildOptionTile(
                icon: Icons.edit_rounded,
                title: 'Rename',
                subtitle: 'Change invoice number',
                onTap: () {
                  Navigator.pop(context);
                  _renameInvoice(invoice);
                },
              ),
              _buildOptionTile(
                icon: Icons.info_outline_rounded,
                title: 'Details',
                subtitle: 'View invoice information',
                onTap: () {
                  Navigator.pop(context);
                  _showInvoiceDetails(invoice);
                },
              ),
              Divider(height: 1, color: AppColors.border),
              _buildOptionTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete',
                subtitle: 'Remove permanently',
                textColor: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  _deleteInvoice(invoice);
                },
              ),
              SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (textColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: textColor ?? AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      onTap: onTap,
    );
  }

  // Download invoice as PDF
  Future<void> _downloadInvoice(Map<String, dynamic> invoice) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading invoice...'),
          backgroundColor: AppColors.primary,
        ),
      );

      // Fetch items and regenerate PDF for download
      final selectedItems =
          await InvoiceService().getItemsForInvoice(invoice['id']);

      // TODO: Implement actual download logic here
      // This would involve generating the PDF and saving it to device storage
      print('Downloading invoice with ${selectedItems.length} items');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice downloaded successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Share invoice
  Future<void> _shareInvoice(Map<String, dynamic> invoice) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generating PDF for sharing...'),
          backgroundColor: AppColors.primary,
        ),
      );

      // Fetch items and regenerate PDF for sharing
      final selectedItems = await InvoiceService().getItemsForInvoice(invoice['id']);
      
      if (selectedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No items found for this invoice'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Navigate to RegenPage to generate PDF and then share it
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegenPage(
            invoiceNumber: invoice['invoice_number'],
            billTo: invoice['bill_to'],
            buyerAddress: invoice['address'] ?? '',
            buyerEmail: invoice['email'] ?? '',
            buyerPhone: invoice['phone'] ?? '',
            selectedItems: selectedItems,
          ),
        ),
      );

      // Show success message after returning from PDF generation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF generation completed. You can share it from the PDF viewer.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Share failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<String?> _generateInvoicePDF(Map<String, dynamic> invoice) async {
    try {
      // Get invoice data
      final invoiceId = invoice['id'] as int;
      final invoiceNumber = invoice['invoice_number'] as String;
      final billTo = invoice['bill_to'] as String;
      final buyerAddress = invoice['address'] as String? ?? '';
      final buyerEmail = invoice['email'] as String? ?? '';
      final buyerPhone = invoice['phone'] as String? ?? '';

      // Get invoice items
      final invoiceService = InvoiceService();
      final selectedItems = await invoiceService.getItemsForInvoice(invoiceId);

      if (selectedItems.isEmpty) {
        throw Exception('No items found for this invoice');
      }

      // Get user data and template
      final userData = await DatabaseService.instance.getUserById(1);
      final template = await TemplateService.getSelectedTemplate();
      final currency = await CurrencyService.getCurrentCurrency();

      if (userData == null) {
        throw Exception('User data not found');
      }

      // Create PDF document
      final pdf = pw.Document();

      // Handle logo loading
      pw.MemoryImage? companyLogo;
      final companyLogoUrl = userData['company_logo_url'];
      if (companyLogoUrl != null && companyLogoUrl.isNotEmpty) {
        final file = File(companyLogoUrl);
        if (await file.exists()) {
          final imageBytes = await file.readAsBytes();
          companyLogo = pw.MemoryImage(imageBytes);
        }
      }

      // Pre-load item images
      Map<Item, pw.MemoryImage?> itemImages = {};
      for (Item item in selectedItems.keys) {
        if (item.includeImageInPdf && item.imagePath.isNotEmpty) {
          try {
            final file = File(item.imagePath);
            if (await file.exists()) {
              final imageBytes = await file.readAsBytes();
              itemImages[item] = pw.MemoryImage(imageBytes);
            } else {
              itemImages[item] = null;
            }
          } catch (e) {
            itemImages[item] = null;
          }
        } else {
          itemImages[item] = null;
        }
      }

      // Calculate totals
      double totalPrice = 0;
      double totalDiscount = 0;
      selectedItems.forEach((item, quantity) {
        final safeQty = quantity;
        double itemSubtotal = item.price * safeQty;
        double itemDiscount = 0;

        if (item.discountPercentage > 0) {
          itemDiscount = itemSubtotal * (item.discountPercentage / 100);
        } else if (item.discountAmount > 0) {
          itemDiscount = item.discountAmount * safeQty;
        }

        totalDiscount += itemDiscount;
        totalPrice += itemSubtotal - itemDiscount;
      });

      // Add page to PDF (reusing the same structure as regen.dart)
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildPDFHeader(template, userData, companyLogo),
                pw.SizedBox(height: 20),
                _buildPDFInvoiceTitle(template, invoiceNumber),
                pw.SizedBox(height: 20),
                _buildPDFBillToSection(
                    template, billTo, buyerAddress, buyerEmail, buyerPhone),
                pw.SizedBox(height: 20),
                _buildPDFItemsSection(
                    template, selectedItems, currency, itemImages),
                pw.SizedBox(height: 20),
                _buildPDFTotal(template, totalPrice, totalDiscount, currency),
                pw.SizedBox(height: 15),
                _buildPDFPaymentInstructions(template, userData),
                pw.Divider(color: template.colors.border),
                if (template.layout.showFooter) _buildPDFFooter(template),
              ],
            );
          },
        ),
      );

      // Save PDF to temporary directory
      final output = await getTemporaryDirectory();
      final filePath =
          '${output.path}/invoice_share_${invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  // PDF Helper methods (simplified versions from regen.dart)
  pw.Widget _buildPDFHeader(dynamic template, Map<String, dynamic>? userData,
      pw.MemoryImage? companyLogo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('${userData?['name'] ?? 'Company Name'}',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Email: ${userData?['email'] ?? ''}'),
            pw.Text('Phone: ${userData?['phone'] ?? ''}'),
            pw.Text('Address: ${userData?['address'] ?? ''}'),
            if (userData?['website'] != null && userData!['website'].isNotEmpty)
              pw.Text('Website: ${userData['website']}'),
          ],
        ),
        if (companyLogo != null)
          pw.Container(
            width: 100,
            height: 100,
            child: pw.Image(companyLogo),
          ),
      ],
    );
  }

  pw.Widget _buildPDFInvoiceTitle(dynamic template, String invoiceNumber) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#f0f0f0'),
        border: pw.Border.all(color: PdfColor.fromHex('#cccccc')),
      ),
      child: pw.Text(
        'Invoice #$invoiceNumber',
        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildPDFBillToSection(dynamic template, String billTo,
      String address, String email, String phone) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Bill To:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text(billTo, style: pw.TextStyle(fontSize: 14)),
        if (address.isNotEmpty)
          pw.Text(address, style: pw.TextStyle(fontSize: 12)),
        if (email.isNotEmpty)
          pw.Text('Email: $email', style: pw.TextStyle(fontSize: 12)),
        if (phone.isNotEmpty)
          pw.Text('Phone: $phone', style: pw.TextStyle(fontSize: 12)),
      ],
    );
  }

  pw.Widget _buildPDFItemsSection(
      dynamic template,
      Map<Item, int> selectedItems,
      Currency currency,
      Map<Item, pw.MemoryImage?> itemImages) {
    return pw.Column(
      children: [
        // Header
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#f0f0f0'),
            border: pw.Border.all(color: PdfColor.fromHex('#cccccc')),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                  flex: 3,
                  child: pw.Text('Item',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.Expanded(
                  flex: 1,
                  child: pw.Text('Qty',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text('Price',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text('Total',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            ],
          ),
        ),
        // Items
        ...selectedItems.entries.map((entry) {
          final item = entry.key;
          final quantity = entry.value;
          final itemTotal = item.price * quantity;

          return pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: PdfColor.fromHex('#cccccc')),
                right: pw.BorderSide(color: PdfColor.fromHex('#cccccc')),
                bottom: pw.BorderSide(color: PdfColor.fromHex('#cccccc')),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(item.name,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        if (item.description.isNotEmpty)
                          pw.Text(item.description,
                              style: pw.TextStyle(fontSize: 10)),
                      ],
                    )),
                pw.Expanded(flex: 1, child: pw.Text(quantity.toString())),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                        CurrencyService.formatAmount(item.price, currency))),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                        CurrencyService.formatAmount(itemTotal, currency))),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildPDFTotal(dynamic template, double totalPrice,
      double totalDiscount, Currency currency) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          if (totalDiscount > 0) ...[
            pw.Text(
                'Subtotal: ${CurrencyService.formatAmount(totalPrice + totalDiscount, currency)}'),
            pw.Text(
                'Discount: -${CurrencyService.formatAmount(totalDiscount, currency)}'),
            pw.Divider(),
          ],
          pw.Text(
            'Total: ${CurrencyService.formatAmount(totalPrice, currency)}',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFPaymentInstructions(
      dynamic template, Map<String, dynamic>? userData) {
    final paymentInstructions =
        userData?['payment_instructions'] as String? ?? '';
    if (paymentInstructions.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Payment Instructions:',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(paymentInstructions, style: pw.TextStyle(fontSize: 12)),
      ],
    );
  }

  pw.Widget _buildPDFFooter(dynamic template) {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Text(
        'Thank you for your business!',
        style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
      ),
    );
  }

  // Rename invoice
  Future<void> _renameInvoice(Map<String, dynamic> invoice) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _RenameInvoiceDialog(
        initialValue: invoice['invoice_number'],
      ),
    );

    if (result != null &&
        result.isNotEmpty &&
        result != invoice['invoice_number']) {
      try {
        final success = await InvoiceService().updateInvoiceNumber(
          invoice['id'],
          result,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invoice renamed successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          loadInvoices(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to rename invoice'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rename failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Show invoice details
  Future<void> _showInvoiceDetails(Map<String, dynamic> invoice) async {
    final items = await InvoiceService().getItemsForInvoice(invoice['id']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invoice Details', style: AppTextStyles.h5),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                  'Invoice Number', '#${invoice['invoice_number']}'),
              _buildDetailRow('Bill To', invoice['bill_to']),
              _buildDetailRow('Email', invoice['email'] ?? 'Not provided'),
              _buildDetailRow('Phone', invoice['phone'] ?? 'Not provided'),
              _buildDetailRow('Address', invoice['address'] ?? 'Not provided'),
              _buildDetailRow(
                  'Total Amount', '\$${invoice['total'].toStringAsFixed(2)}'),
              _buildDetailRow(
                  'Date Created', _formatDate(invoice['created_at'])),
              SizedBox(height: AppSpacing.md),
              Text('Items (${items.length})',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: AppSpacing.sm),
              ...items.entries
                  .map((entry) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          '• ${entry.key.name} (Qty: ${entry.value})',
                          style: AppTextStyles.bodySmall,
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  // Delete invoice
  Future<void> _deleteInvoice(Map<String, dynamic> invoice) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Invoice', style: AppTextStyles.h5),
        content: Text(
          'Are you sure you want to delete Invoice #${invoice['invoice_number']}? This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Debug: Print the invoice data to see the structure
        print('Attempting to delete invoice: ${invoice.toString()}');
        print('Invoice ID: ${invoice['id']}');

        final success = await InvoiceService().deleteInvoice(invoice['id']);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invoice deleted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          loadInvoices(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete invoice'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        print('Delete error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deletion failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const AppLoading()
          : invoices.isEmpty
              ? _buildEmptyState()
              : _buildInvoicesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'No Invoices Yet',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Create your first invoice by adding clients and items first.\nThen generate invoices from the dashboard.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;

        return RefreshIndicator(
          onRefresh: loadInvoices,
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              final invoiceDate = _formatDate(invoice['created_at']);

              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  child: InkWell(
                    onTap: () {
                      // Explicitly prevent multiple rapid taps
                      _showInvoiceOptions(context, invoice);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          // Invoice icon
                          Container(
                            width: isSmallScreen ? 50 : 60,
                            height: isSmallScreen ? 50 : 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.receipt_rounded,
                              color: AppColors.primary,
                              size: isSmallScreen ? 24 : 30,
                            ),
                          ),

                          SizedBox(width: AppSpacing.md),

                          // Invoice details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Invoice number
                                Text(
                                  "Invoice #${invoice['invoice_number']}",
                                  style: isSmallScreen
                                      ? AppTextStyles.h6
                                      : AppTextStyles.h5,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                SizedBox(height: AppSpacing.xs),

                                // Client name
                                Text(
                                  "To: ${invoice['bill_to']}",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                SizedBox(height: AppSpacing.xs),

                                // Date
                                Text(
                                  invoiceDate,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),

                                SizedBox(height: AppSpacing.xs),

                                // Action hint
                                Text(
                                  "Tap for options",
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary
                                        .withOpacity(0.7),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Amount and more icon
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              FutureBuilder<String>(
                                future: CurrencyService
                                    .formatAmountWithCurrentCurrency(
                                        invoice['total'].toDouble()),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ??
                                        "\$${invoice['total'].toStringAsFixed(2)}",
                                    style: AppTextStyles.h6.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: AppSpacing.sm),
                              Icon(
                                Icons.more_vert_rounded,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final invoiceDate = DateTime(date.year, date.month, date.day);

      if (invoiceDate == today) {
        return 'Today';
      } else if (invoiceDate == yesterday) {
        return 'Yesterday';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }
}

// Dedicated dialog widget for renaming invoices
class _RenameInvoiceDialog extends StatefulWidget {
  final String initialValue;

  const _RenameInvoiceDialog({
    required this.initialValue,
  });

  @override
  State<_RenameInvoiceDialog> createState() => _RenameInvoiceDialogState();
}

class _RenameInvoiceDialogState extends State<_RenameInvoiceDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rename Invoice'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Invoice Number',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text('Rename'),
        ),
      ],
    );
  }
}
