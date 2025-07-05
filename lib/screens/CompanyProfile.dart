import 'package:flutter/material.dart';
import 'package:invoiceapp/components/CustomTextField.dart';
import 'package:invoiceapp/components/ScreenHeader.dart';
import 'package:invoiceapp/components/BottomActionBar.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';
import 'package:invoiceapp/services/database_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController address3Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    address1Controller.dispose();
    address2Controller.dispose();
    address3Controller.dispose();
    cityController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    String fullAddress =
        "${address1Controller.text}, ${address2Controller.text}, ${address3Controller.text}, ${cityController.text}";

    try {
      await DatabaseService.instance.updateUserDetails(
        userId: 1, // Only one user
        address: fullAddress,
        phone: phoneController.text,
        website: websiteController.text,
        email: emailController.text,
      );

      Navigator.pushNamed(context, "/paymentinstructions");
    } catch (e) {
      print("Failed to update profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to save profile. Please try again.",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const ScreenHeader(
                        title: 'Complete\nYour Profile',
                        subtitle:
                            "Add your business details for professional invoices",
                      ),
                      SizedBox(height: AppSpacing.xl),

                      // Form fields
                      AppTextField(
                        controller: address1Controller,
                        labelText: "Address Line 1",
                        hintText: "Enter address line 1",
                        prefixIcon: Icons.location_on_rounded,
                      ),
                      SizedBox(height: AppSpacing.md),

                      AppTextField(
                        controller: address2Controller,
                        labelText: "Address Line 2",
                        hintText: "Enter address line 2",
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      SizedBox(height: AppSpacing.md),

                      AppTextField(
                        controller: address3Controller,
                        labelText: "Address Line 3",
                        hintText: "Enter address line 3",
                        prefixIcon: Icons.location_city_rounded,
                      ),
                      SizedBox(height: AppSpacing.md),

                      AppTextField(
                        controller: cityController,
                        labelText: "City",
                        hintText: "Enter city",
                        prefixIcon: Icons.location_city,
                      ),
                      SizedBox(height: AppSpacing.md),

                      AppTextField(
                        controller: emailController,
                        labelText: "Email",
                        hintText: "Enter email address",
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_rounded,
                      ),
                      SizedBox(height: AppSpacing.md),

                      AppTextField(
                        controller: phoneController,
                        labelText: "Phone Number",
                        hintText: "Enter phone number",
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_rounded,
                      ),
                      SizedBox(height: AppSpacing.md),

                      AppTextField(
                        controller: websiteController,
                        labelText: "Website",
                        hintText: "Enter website URL",
                        keyboardType: TextInputType.url,
                        prefixIcon: Icons.language_rounded,
                      ),
                      SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),

              // Bottom action buttons
              BottomActionBar(
                primaryButtonText: "Continue",
                onPrimaryPressed: _saveProfile,
                primaryButtonLoading: _isLoading,
                primaryButtonEnabled: !_isLoading,
                onSkipPressed: () =>
                    Navigator.pushNamed(context, "/paymentinstructions"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
