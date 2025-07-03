import 'package:flutter/material.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';
import 'package:invoiceapp/components/CustomTextField.dart';
import 'package:invoiceapp/components/ButtonComponent.dart';
import 'package:invoiceapp/components/AppAppBar.dart';
import 'package:invoiceapp/services/client_service.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  Future<void> _saveClient() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ClientService.insertClient(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          note: _noteController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Client added successfully!',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          Navigator.pushNamed(
            context,
            "/dashboard",
            arguments: 2,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to add client. Please try again.',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Add New Client',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Client Information',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'Add the client details to create professional invoices',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xl),

                        // Form fields
                        AppTextField(
                          controller: _nameController,
                          labelText: 'Client Name *',
                          hintText: 'Enter client name',
                          prefixIcon: Icons.person_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter client name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppSpacing.md),

                        AppTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Enter email address',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_rounded,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final emailRegex =
                                  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppSpacing.md),

                        AppTextField(
                          controller: _phoneController,
                          labelText: 'Phone Number',
                          hintText: 'Enter phone number',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_rounded,
                        ),
                        SizedBox(height: AppSpacing.md),

                        AppTextField(
                          controller: _addressController,
                          labelText: 'Address',
                          hintText: 'Enter client address',
                          prefixIcon: Icons.location_on_rounded,
                          maxLines: 2,
                        ),
                        SizedBox(height: AppSpacing.md),

                        AppTextField(
                          controller: _noteController,
                          labelText: 'Note',
                          hintText: 'Additional notes (optional)',
                          prefixIcon: Icons.note_rounded,
                          maxLines: 3,
                        ),
                        SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),

              // Save button
              AppButton(
                text: 'Save Client',
                onPressed: _isLoading ? null : _saveClient,
                loading: _isLoading,
                size: AppButtonSize.large,
                fullWidth: true,
                icon: Icons.save_rounded,
                iconRight: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
