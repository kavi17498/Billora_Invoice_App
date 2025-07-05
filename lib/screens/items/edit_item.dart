import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoiceapp/services/item_service.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';
import 'package:invoiceapp/components/CustomTextField.dart';
import 'package:invoiceapp/components/ButtonComponent.dart';
import 'package:invoiceapp/components/AppAppBar.dart';
import 'package:invoiceapp/components/ScreenHeader.dart';
import 'package:invoiceapp/components/AppLoading.dart';

class EditItemPage extends StatefulWidget {
  final int itemId;
  const EditItemPage({super.key, required this.itemId});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  Item? _item;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  String? _imagePath;
  bool _includeImageInPdf = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadItem() async {
    try {
      _item = await ItemService.getItemById(widget.itemId);
      if (_item != null && mounted) {
        _nameController.text = _item!.name;
        _descriptionController.text = _item!.description;
        _priceController.text = _item!.price.toString();
        _costController.text = _item!.cost.toString();
        _quantityController.text = _item!.quantity.toString();
        _imagePath = _item!.imagePath.isNotEmpty ? _item!.imagePath : null;
        _includeImageInPdf = _item!.includeImageInPdf;
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to load item: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || _item == null) return;

    setState(() => _isSaving = true);

    try {
      final updated = Item(
        id: _item!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        cost: double.tryParse(_costController.text) ?? 0.0,
        imagePath: _imagePath ?? '',
        type: 'item', // Always 'item' now
        quantity: int.tryParse(_quantityController.text) ?? 1,
        discountPercentage:
            _item!.discountPercentage, // Keep existing discount values
        discountAmount: _item!.discountAmount, // Keep existing discount values
        includeImageInPdf: _includeImageInPdf,
      );

      await ItemService.updateItem(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Item updated successfully!',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to update item: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1024,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null && mounted) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError("Failed to pick image. Please try again.");
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
    });
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Delete Item",
          style: AppTextStyles.h5,
        ),
        content: Text(
          "Are you sure you want to delete this item? This action cannot be undone.",
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Delete",
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && _item != null) {
      try {
        await ItemService.deleteItem(_item!.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Item deleted successfully!',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          _showError('Failed to delete item: ${e.toString()}');
        }
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const AppLoading(),
      );
    }

    if (_item == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AppAppBar(title: 'Edit Item'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.error,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Item not found',
                style: AppTextStyles.h4,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'The item you\'re trying to edit doesn\'t exist.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Edit Item',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.error,
            ),
            onPressed: _deleteItem,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: AppSpacing.lg,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Header
                        ScreenHeader(
                          title: 'Edit Item',
                          subtitle: 'Update your item information',
                        ),
                        SizedBox(height: AppSpacing.xl),

                        // Form fields with responsive width
                        Container(
                          width: screenWidth > 600 ? 500 : double.infinity,
                          child: Column(
                            children: [
                              // Item Name
                              AppTextField(
                                controller: _nameController,
                                labelText: 'Item Name *',
                                hintText: 'Enter item name',
                                prefixIcon: Icons.inventory_2_rounded,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter item name';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Item name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: AppSpacing.md),

                              // Description
                              AppTextField(
                                controller: _descriptionController,
                                labelText: 'Description',
                                hintText: 'Brief description (optional)',
                                prefixIcon: Icons.description_rounded,
                                maxLines: 3,
                              ),
                              SizedBox(height: AppSpacing.md),

                              // Price and Cost in a Row
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      controller: _priceController,
                                      labelText: 'Selling Price *',
                                      hintText: '0.00',
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      prefixIcon: Icons.attach_money_rounded,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter price';
                                        }
                                        final price = double.tryParse(value);
                                        if (price == null || price < 0) {
                                          return 'Enter valid price';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: AppTextField(
                                      controller: _costController,
                                      labelText: 'Cost Price',
                                      hintText: '0.00',
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      prefixIcon: Icons.money_off_rounded,
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          final cost = double.tryParse(value);
                                          if (cost == null || cost < 0) {
                                            return 'Enter valid cost';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.md),

                              // Quantity
                              AppTextField(
                                controller: _quantityController,
                                labelText: 'Default Quantity *',
                                hintText: '1',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.numbers_rounded,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter quantity';
                                  }
                                  final quantity = int.tryParse(value);
                                  if (quantity == null || quantity < 1) {
                                    return 'Enter valid quantity (minimum 1)';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: AppSpacing.xs),
                              Text(
                                'This is the default quantity that will be pre-filled when creating invoices. You can change it for each invoice.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: AppSpacing.lg),

                              // Image section
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    if (_imagePath == null) ...[
                                      Padding(
                                        padding: EdgeInsets.all(AppSpacing.lg),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.image_outlined,
                                              size: 48,
                                              color: AppColors.textSecondary,
                                            ),
                                            SizedBox(height: AppSpacing.sm),
                                            Text(
                                              'Add Item Image (Optional)',
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            SizedBox(height: AppSpacing.md),
                                            AppButton(
                                              text: 'Choose Image',
                                              onPressed: _pickImage,
                                              variant: AppButtonVariant.outline,
                                              icon: Icons.photo_library_rounded,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ] else ...[
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.file(
                                              File(_imagePath!),
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: _removeImage,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.error,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.shadow
                                                          .withOpacity(0.2),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(AppSpacing.md),
                                        child: AppButton(
                                          text: 'Change Image',
                                          onPressed: _pickImage,
                                          variant: AppButtonVariant.outline,
                                          size: AppButtonSize.small,
                                          icon: Icons.edit_rounded,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(height: AppSpacing.lg),

                              // Include in PDF toggle
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(12),
                                  color: AppColors.surface,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf_rounded,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Include Image in PDF',
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: AppSpacing.xs),
                                          Text(
                                            'When enabled, the item image will appear as a small thumbnail in generated invoice PDFs',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.md),
                                    Switch.adaptive(
                                      value: _includeImageInPdf,
                                      onChanged: (value) {
                                        setState(() {
                                          _includeImageInPdf = value;
                                        });
                                      },
                                      activeColor: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppSpacing.xl * 2),
                            ],
                          ),
                        ),

                        // Action buttons
                        Container(
                          width: screenWidth > 600 ? 500 : double.infinity,
                          child: Column(
                            children: [
                              // Save button
                              AppButton(
                                text: 'Save Changes',
                                onPressed: _isSaving ? null : _saveChanges,
                                loading: _isSaving,
                                size: AppButtonSize.large,
                                fullWidth: true,
                                icon: Icons.save_rounded,
                                iconRight: true,
                              ),
                              SizedBox(height: AppSpacing.md),

                              // Delete button
                              AppButton(
                                text: 'Delete Item',
                                onPressed: _deleteItem,
                                variant: AppButtonVariant.error,
                                size: AppButtonSize.large,
                                fullWidth: true,
                                icon: Icons.delete_outline,
                                iconRight: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
