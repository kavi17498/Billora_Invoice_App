import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';
import 'package:invoiceapp/components/CustomTextField.dart';
import 'package:invoiceapp/components/ButtonComponent.dart';
import 'package:invoiceapp/components/AppAppBar.dart';
import 'package:invoiceapp/components/ScreenHeader.dart';
import 'package:invoiceapp/services/item_service.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key});

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  bool _isLoading = false;

  // Controllers for better input management
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final TextEditingController _discountPercentageController =
      TextEditingController();
  final TextEditingController _discountAmountController =
      TextEditingController();

  String? _imagePath;
  bool _includeImageInPdf = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    _discountPercentageController.dispose();
    _discountAmountController.dispose();
    super.dispose();
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
      _includeImageInPdf = false; // Reset the PDF option when image is removed
    });
  }

  void _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final item = Item(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        cost: double.tryParse(_costController.text) ?? 0.0,
        imagePath: _imagePath ?? '',
        type: 'item', // Simplified to just 'item'
        quantity: int.tryParse(_quantityController.text) ?? 1,
        discountPercentage:
            double.tryParse(_discountPercentageController.text) ?? 0.0,
        discountAmount: double.tryParse(_discountAmountController.text) ?? 0.0,
        includeImageInPdf: _includeImageInPdf,
      );

      await ItemService.insertItem(item);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Item added successfully!',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pushNamed(context, "/dashboard", arguments: 3);
      }
    } catch (e) {
      if (mounted) {
        _showError("Failed to save item. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenSize.height < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
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
                    vertical: isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Header
                        const ScreenHeader(
                          title: 'Add New Item',
                          subtitle:
                              'Create items for your invoices - services, products, consultations, anything billable',
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
                                hintText:
                                    'e.g., Medical Consultation, Web Design, Medicine',
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
                                hintText:
                                    'Brief description of the item (optional)',
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

                              // Discount section
                              Container(
                                padding: EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_offer_outlined,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                        SizedBox(width: AppSpacing.sm),
                                        Text(
                                          'Discount (Optional)',
                                          style: AppTextStyles.h6.copyWith(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Add a default discount for this item. You can use either percentage or fixed amount.',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.md),

                                    // Discount fields in a row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AppTextField(
                                            controller:
                                                _discountPercentageController,
                                            labelText: 'Discount %',
                                            hintText: '0',
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                            prefixIcon: Icons.percent_rounded,
                                            validator: (value) {
                                              if (value != null &&
                                                  value.isNotEmpty) {
                                                final percentage =
                                                    double.tryParse(value);
                                                if (percentage == null ||
                                                    percentage < 0 ||
                                                    percentage > 100) {
                                                  return 'Enter valid percentage (0-100)';
                                                }
                                                // Check if both discount fields are filled
                                                if (_discountAmountController
                                                    .text.isNotEmpty) {
                                                  return 'Use either percentage OR amount, not both';
                                                }
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              // Clear the other discount field if this one is being used
                                              if (value.isNotEmpty &&
                                                  _discountAmountController
                                                      .text.isNotEmpty) {
                                                _discountAmountController
                                                    .clear();
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: AppTextField(
                                            controller:
                                                _discountAmountController,
                                            labelText: 'Discount Amount',
                                            hintText: '0.00',
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                            prefixIcon: Icons.money_off_rounded,
                                            validator: (value) {
                                              if (value != null &&
                                                  value.isNotEmpty) {
                                                final amount =
                                                    double.tryParse(value);
                                                if (amount == null ||
                                                    amount < 0) {
                                                  return 'Enter valid amount';
                                                }
                                                // Check if both discount fields are filled
                                                if (_discountPercentageController
                                                    .text.isNotEmpty) {
                                                  return 'Use either percentage OR amount, not both';
                                                }
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              // Clear the other discount field if this one is being used
                                              if (value.isNotEmpty &&
                                                  _discountPercentageController
                                                      .text.isNotEmpty) {
                                                _discountPercentageController
                                                    .clear();
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppSpacing.lg),

                              // Image picker section
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

                              // Option to include image in PDF (only show if image is selected)
                              if (_imagePath != null) ...[
                                SizedBox(height: AppSpacing.md),
                                Container(
                                  padding: EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.picture_as_pdf_outlined,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Include image in PDF invoices',
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: AppSpacing.xs),
                                            Text(
                                              'Show this item\'s image in generated invoices (small size)',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
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
                              ],

                              SizedBox(height: AppSpacing.xl * 2),
                            ],
                          ),
                        ),

                        // Save button
                        Container(
                          width: screenWidth > 600 ? 500 : double.infinity,
                          child: AppButton(
                            text: 'Save Item',
                            onPressed: _isLoading ? null : _saveItem,
                            loading: _isLoading,
                            size: AppButtonSize.large,
                            fullWidth: true,
                            icon: Icons.save_rounded,
                            iconRight: true,
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
