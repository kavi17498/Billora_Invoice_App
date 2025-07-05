import 'package:flutter/material.dart';
import 'package:invoiceapp/models/invoice_template.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';

class TemplatePreviewScreen extends StatelessWidget {
  final InvoiceTemplate template;

  const TemplatePreviewScreen({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Preview: ${template.name}', style: AppTextStyles.h4),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTemplateInfo(),
            const SizedBox(height: AppSpacing.lg),
            _buildInvoicePreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateInfo() {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Template Information',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow('Name', template.name),
            _buildInfoRow('Description', template.description),
            _buildInfoRow(
                'Header Style', template.layout.headerStyle.toUpperCase()),
            _buildInfoRow(
                'Table Style', template.layout.tableStyle.toUpperCase()),
            _buildInfoRow('Show Logo', template.layout.showLogo ? 'Yes' : 'No'),
            _buildInfoRow(
                'Show Footer', template.layout.showFooter ? 'Yes' : 'No'),
            if (template.layout.showFooter)
              _buildInfoRow('Footer Text', template.layout.footerText),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Color Scheme',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _buildColorSwatch('Primary', template.colors.primary),
                const SizedBox(width: AppSpacing.sm),
                _buildColorSwatch('Secondary', template.colors.secondary),
                const SizedBox(width: AppSpacing.sm),
                _buildColorSwatch('Accent', template.colors.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(String label, dynamic pdfColor) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _pdfColorToFlutterColor(pdfColor),
            borderRadius: BorderRadius.circular(AppSizing.radiusMD),
            border: Border.all(color: AppColors.border),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInvoicePreview() {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Preview',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _pdfColorToFlutterColor(template.colors.background),
                borderRadius: BorderRadius.circular(AppSizing.radiusMD),
                border: Border.all(
                    color: _pdfColorToFlutterColor(template.colors.border)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildBillToSection(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildItemsTable(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTotal(),
                    if (template.layout.showFooter) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _buildFooter(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    switch (template.layout.headerStyle) {
      case 'minimal':
        return _buildMinimalHeader();
      case 'centered':
        return _buildCenteredHeader();
      case 'split':
      default:
        return _buildSplitHeader();
    }
  }

  Widget _buildMinimalHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INVOICE',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _pdfColorToFlutterColor(template.colors.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Invoice #INV-001',
          style: TextStyle(
            fontSize: 14,
            color: _pdfColorToFlutterColor(template.colors.text),
          ),
        ),
      ],
    );
  }

  Widget _buildCenteredHeader() {
    return Column(
      children: [
        if (template.layout.showLogo)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _pdfColorToFlutterColor(template.colors.secondary),
              borderRadius: BorderRadius.circular(AppSizing.radiusMD),
            ),
            child: Icon(
              Icons.business,
              color: _pdfColorToFlutterColor(template.colors.primary),
              size: 32,
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Your Company Name',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _pdfColorToFlutterColor(template.colors.text),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'INVOICE',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _pdfColorToFlutterColor(template.colors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildSplitHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (template.layout.showLogo)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _pdfColorToFlutterColor(template.colors.secondary),
              borderRadius: BorderRadius.circular(AppSizing.radiusMD),
            ),
            child: Icon(
              Icons.business,
              color: _pdfColorToFlutterColor(template.colors.primary),
              size: 32,
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Your Company Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _pdfColorToFlutterColor(template.colors.text),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'company@example.com',
              style: TextStyle(
                fontSize: 12,
                color: _pdfColorToFlutterColor(template.colors.text),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBillToSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _pdfColorToFlutterColor(template.colors.secondary),
        borderRadius: BorderRadius.circular(AppSizing.radiusMD),
        border:
            Border.all(color: _pdfColorToFlutterColor(template.colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BILL TO',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _pdfColorToFlutterColor(template.colors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'John Doe',
            style: TextStyle(
              fontSize: 14,
              color: _pdfColorToFlutterColor(template.colors.text),
            ),
          ),
          Text(
            'john.doe@example.com',
            style: TextStyle(
              fontSize: 12,
              color: _pdfColorToFlutterColor(template.colors.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizing.radiusMD),
        border:
            Border.all(color: _pdfColorToFlutterColor(template.colors.border)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: template.layout.tableStyle == 'bordered' ||
                      template.layout.tableStyle == 'striped'
                  ? _pdfColorToFlutterColor(template.colors.secondary)
                  : Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizing.radiusMD),
                topRight: Radius.circular(AppSizing.radiusMD),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Item',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _pdfColorToFlutterColor(template.colors.text),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Qty',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _pdfColorToFlutterColor(template.colors.text),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Price',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _pdfColorToFlutterColor(template.colors.text),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Sample rows
          ...List.generate(3, (index) {
            final isEven = index % 2 == 0;
            return Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: template.layout.tableStyle == 'striped' && !isEven
                    ? _pdfColorToFlutterColor(template.colors.secondary)
                    : Colors.transparent,
                border: template.layout.tableStyle == 'bordered'
                    ? Border(
                        bottom: BorderSide(
                          color:
                              _pdfColorToFlutterColor(template.colors.border),
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Sample Item ${index + 1}',
                      style: TextStyle(
                        color: _pdfColorToFlutterColor(template.colors.text),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: _pdfColorToFlutterColor(template.colors.text),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Rs. ${(100 * (index + 1)).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _pdfColorToFlutterColor(template.colors.text),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: _pdfColorToFlutterColor(template.colors.secondary),
            borderRadius: BorderRadius.circular(AppSizing.radiusMD),
          ),
          child: Text(
            'Total: Rs. 600.00',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _pdfColorToFlutterColor(template.colors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        template.layout.footerText,
        style: TextStyle(
          fontSize: 12,
          color: _pdfColorToFlutterColor(template.colors.text),
        ),
      ),
    );
  }

  Color _pdfColorToFlutterColor(dynamic pdfColor) {
    final r = (pdfColor.red * 255).round();
    final g = (pdfColor.green * 255).round();
    final b = (pdfColor.blue * 255).round();
    return Color.fromARGB(255, r, g, b);
  }
}
