import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/invoiceGen/regen.dart';
import 'package:invoiceapp/services/invoice_service.dart';
import 'package:invoiceapp/services/item_service.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';
import 'package:invoiceapp/components/AppCard.dart';
import 'package:invoiceapp/components/AppLoading.dart';

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
                    onTap: () => regenerateInvoice(invoice),
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

                                // Regenerate hint
                                Text(
                                  "Tap to regenerate with current template",
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary
                                        .withOpacity(0.7),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Amount and arrow
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "\$${invoice['total'].toStringAsFixed(2)}",
                                style: AppTextStyles.h6.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: AppSpacing.sm),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
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
