import 'package:flutter/material.dart';
import 'package:invoiceapp/models/invoice_template.dart';
import 'package:invoiceapp/services/template_service.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';
import 'package:pdf/pdf.dart';

class TemplateEditorScreen extends StatefulWidget {
  final InvoiceTemplate? template;

  const TemplateEditorScreen({super.key, this.template});

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _footerController;

  late String _headerStyle;
  late String _tableStyle;
  late bool _showLogo;
  late bool _showFooter;

  // Color selections
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _accentColor;
  late Color _textColor;
  late Color _backgroundColor;
  late Color _borderColor;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.template != null) {
      // Edit existing template
      _nameController = TextEditingController(text: widget.template!.name);
      _descriptionController =
          TextEditingController(text: widget.template!.description);
      _footerController =
          TextEditingController(text: widget.template!.layout.footerText);

      _headerStyle = widget.template!.layout.headerStyle;
      _tableStyle = widget.template!.layout.tableStyle;
      _showLogo = widget.template!.layout.showLogo;
      _showFooter = widget.template!.layout.showFooter;

      _primaryColor = _pdfColorToFlutterColor(widget.template!.colors.primary);
      _secondaryColor =
          _pdfColorToFlutterColor(widget.template!.colors.secondary);
      _accentColor = _pdfColorToFlutterColor(widget.template!.colors.accent);
      _textColor = _pdfColorToFlutterColor(widget.template!.colors.text);
      _backgroundColor =
          _pdfColorToFlutterColor(widget.template!.colors.background);
      _borderColor = _pdfColorToFlutterColor(widget.template!.colors.border);
    } else {
      // Create new template
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _footerController =
          TextEditingController(text: 'Thank you for your business!');

      _headerStyle = 'split';
      _tableStyle = 'bordered';
      _showLogo = true;
      _showFooter = true;

      _primaryColor = Colors.blue[800]!;
      _secondaryColor = Colors.blue[100]!;
      _accentColor = Colors.blue[600]!;
      _textColor = Colors.grey[900]!;
      _backgroundColor = Colors.white;
      _borderColor = Colors.grey[300]!;
    }
  }

  Color _pdfColorToFlutterColor(PdfColor pdfColor) {
    final r = (pdfColor.red * 255).round();
    final g = (pdfColor.green * 255).round();
    final b = (pdfColor.blue * 255).round();
    return Color.fromARGB(255, r, g, b);
  }

  PdfColor _flutterColorToPdfColor(Color color) {
    return PdfColor(color.red / 255.0, color.green / 255.0, color.blue / 255.0);
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final template = InvoiceTemplate(
        id: widget.template?.id ?? 0,
        name: _nameController.text,
        description: _descriptionController.text,
        colors: TemplateColors(
          primary: _flutterColorToPdfColor(_primaryColor),
          secondary: _flutterColorToPdfColor(_secondaryColor),
          accent: _flutterColorToPdfColor(_accentColor),
          text: _flutterColorToPdfColor(_textColor),
          background: _flutterColorToPdfColor(_backgroundColor),
          border: _flutterColorToPdfColor(_borderColor),
        ),
        layout: TemplateLayout(
          headerStyle: _headerStyle,
          tableStyle: _tableStyle,
          showLogo: _showLogo,
          showFooter: _showFooter,
          footerText: _footerController.text,
        ),
      );

      if (widget.template != null) {
        await TemplateService.updateTemplate(template);
      } else {
        await TemplateService.saveCustomTemplate(template);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Template ${widget.template != null ? 'updated' : 'created'} successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save template: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.template != null ? 'Edit Template' : 'Create Template',
          style: AppTextStyles.h4,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTemplate,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildColorSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildLayoutSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildPreviewSection(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
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
              'Basic Information',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Template Name',
                hintText: 'Enter template name',
                prefixIcon: const Icon(Icons.label),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMD),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a template name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter template description',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMD),
                ),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection() {
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
              'Color Scheme',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildColorPicker('Primary Color', _primaryColor, (color) {
              setState(() => _primaryColor = color);
            }),
            _buildColorPicker('Secondary Color', _secondaryColor, (color) {
              setState(() => _secondaryColor = color);
            }),
            _buildColorPicker('Accent Color', _accentColor, (color) {
              setState(() => _accentColor = color);
            }),
            _buildColorPicker('Text Color', _textColor, (color) {
              setState(() => _textColor = color);
            }),
            _buildColorPicker('Background Color', _backgroundColor, (color) {
              setState(() => _backgroundColor = color);
            }),
            _buildColorPicker('Border Color', _borderColor, (color) {
              setState(() => _borderColor = color);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(
      String label, Color color, ValueChanged<Color> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showColorPicker(label, color, onChanged),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppSizing.radiusMD),
                border: Border.all(color: AppColors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(
      String title, Color currentColor, ValueChanged<Color> onChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: currentColor,
            onColorChanged: onChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutSection() {
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
              'Layout Settings',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildDropdown(
              'Header Style',
              _headerStyle,
              ['minimal', 'centered', 'split'],
              (value) => setState(() => _headerStyle = value!),
            ),
            _buildDropdown(
              'Table Style',
              _tableStyle,
              ['simple', 'striped', 'bordered'],
              (value) => setState(() => _tableStyle = value!),
            ),
            _buildSwitch('Show Logo', _showLogo, (value) {
              setState(() => _showLogo = value);
            }),
            _buildSwitch('Show Footer', _showFooter, (value) {
              setState(() => _showFooter = value);
            }),
            if (_showFooter)
              TextFormField(
                controller: _footerController,
                decoration: InputDecoration(
                  labelText: 'Footer Text',
                  hintText: 'Enter footer text',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizing.radiusMD),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusMD),
          ),
        ),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option.replaceAll('_', ' ').toUpperCase()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
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
              'Preview',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(AppSizing.radiusMD),
                border: Border.all(color: _borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'INVOICE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        if (_showLogo)
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _secondaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _secondaryColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _borderColor),
                      ),
                      child: const Center(
                        child: Text('Sample Invoice Content'),
                      ),
                    ),
                    const Spacer(),
                    if (_showFooter)
                      Center(
                        child: Text(
                          _footerController.text,
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _footerController.dispose();
    super.dispose();
  }
}

// Simple color picker implementation
class BlockPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const BlockPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () => onColorChanged(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: pickerColor == color ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
