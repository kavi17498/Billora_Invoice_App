import 'package:flutter/material.dart';
import 'package:invoiceapp/models/invoice_template.dart';
import 'package:invoiceapp/services/template_service.dart';
import 'package:invoiceapp/screens/settings/template_editor.dart';
import 'package:invoiceapp/screens/settings/template_preview.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';
import 'package:invoiceapp/components/AppLoading.dart';

class TemplateSettingsScreen extends StatefulWidget {
  const TemplateSettingsScreen({super.key});

  @override
  State<TemplateSettingsScreen> createState() => _TemplateSettingsScreenState();
}

class _TemplateSettingsScreenState extends State<TemplateSettingsScreen> {
  List<InvoiceTemplate> _templates = [];
  InvoiceTemplate? _selectedTemplate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    try {
      final templates = await TemplateService.getAllTemplates();
      final selectedTemplate = await TemplateService.getSelectedTemplate();

      setState(() {
        _templates = templates;
        _selectedTemplate = selectedTemplate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load templates: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectTemplate(InvoiceTemplate template) async {
    try {
      await TemplateService.setSelectedTemplate(template.id);
      setState(() => _selectedTemplate = template);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Template "${template.name}" selected'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select template: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteTemplate(InvoiceTemplate template) async {
    if (template.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cannot delete default template'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusLG),
        ),
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surface,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await TemplateService.deleteTemplate(template.id);
        _loadTemplates();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Template "${template.name}" deleted'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete template: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Invoice Templates", style: AppTextStyles.h4),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TemplateEditorScreen(),
                ),
              );
              if (result == true) {
                _loadTemplates();
              }
            },
            icon: const Icon(Icons.add),
            tooltip: 'Create Template',
          ),
        ],
      ),
      body: _isLoading
          ? const AppLoading()
          : RefreshIndicator(
              onRefresh: _loadTemplates,
              child: _templates.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: _templates.length,
                      itemBuilder: (context, index) {
                        final template = _templates[index];
                        return _buildTemplateCard(template);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TemplateEditorScreen(),
            ),
          );
          if (result == true) {
            _loadTemplates();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No Templates Available',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Create your first invoice template to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(InvoiceTemplate template) {
    final isSelected = _selectedTemplate?.id == template.id;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.radiusLG),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.lg),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getPdfColorAsFlutterColor(template.colors.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizing.radiusMD),
                border: Border.all(
                  color: _getPdfColorAsFlutterColor(template.colors.primary),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.description,
                color: _getPdfColorAsFlutterColor(template.colors.primary),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    template.name,
                    style: AppTextStyles.h6.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (template.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizing.radiusSM),
                    ),
                    child: Text(
                      'Default',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(left: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizing.radiusSM),
                    ),
                    child: Text(
                      'Selected',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xs),
                Text(
                  template.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _buildColorDot(template.colors.primary),
                    const SizedBox(width: AppSpacing.xs),
                    _buildColorDot(template.colors.secondary),
                    const SizedBox(width: AppSpacing.xs),
                    _buildColorDot(template.colors.accent),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      template.layout.headerStyle.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'select':
                    _selectTemplate(template);
                    break;
                  case 'preview':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TemplatePreviewScreen(template: template),
                      ),
                    );
                    break;
                  case 'edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TemplateEditorScreen(template: template),
                      ),
                    ).then((result) {
                      if (result == true) {
                        _loadTemplates();
                      }
                    });
                    break;
                  case 'delete':
                    _deleteTemplate(template);
                    break;
                }
              },
              itemBuilder: (context) => [
                if (!isSelected)
                  const PopupMenuItem<String>(
                    value: 'select',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline),
                        SizedBox(width: 8),
                        Text('Select'),
                      ],
                    ),
                  ),
                const PopupMenuItem<String>(
                  value: 'preview',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('Preview'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                if (!template.isDefault)
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorDot(dynamic pdfColor) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: _getPdfColorAsFlutterColor(pdfColor),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
    );
  }

  Color _getPdfColorAsFlutterColor(dynamic pdfColor) {
    // Convert PdfColor to Flutter Color
    if (pdfColor.toString().contains('PdfColor')) {
      // Extract RGB values from PdfColor
      final r = (pdfColor.red * 255).round();
      final g = (pdfColor.green * 255).round();
      final b = (pdfColor.blue * 255).round();
      return Color.fromARGB(255, r, g, b);
    }
    return Colors.grey;
  }
}
