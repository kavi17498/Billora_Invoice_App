import 'package:flutter/material.dart';
import 'package:invoiceapp/components/CustomTextField.dart';
import 'package:invoiceapp/components/ScreenHeader.dart';
import 'package:invoiceapp/components/BottomActionBar.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';
import 'package:invoiceapp/services/database_service.dart';

class Businessname extends StatefulWidget {
  const Businessname({super.key});

  @override
  State<Businessname> createState() => _BusinessnameState();
}

class _BusinessnameState extends State<Businessname> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    // Ensure the widget is still mounted before proceeding
    if (!mounted) return;

    final businessName = _controller.text.trim();

    if (businessName.isEmpty) {
      _showError("Please enter a business name");
      return;
    }
    if (businessName.length < 3) {
      _showError("Business name must be at least 3 characters");
      return;
    }
    if (businessName.length > 50) {
      _showError("Business name must be less than 50 characters");
      return;
    }

    try {
      _databaseService.insertUser(businessName);
      if (mounted) {
        Navigator.pushNamed(context, "/uploadlogo");
      }
    } catch (e) {
      if (mounted) {
        _showError("Failed to save business name. Please try again.");
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
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenHeight < 600;
    final isLargeScreen = screenHeight > 800;

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05, // 5% of screen width
                    vertical: isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      // Flexible spacing at top
                      SizedBox(
                        height: isSmallScreen
                            ? constraints.maxHeight * 0.08
                            : constraints.maxHeight * 0.15,
                      ),

                      // Header with responsive sizing
                      ScreenHeader(
                        title: "Enter your Business Name",
                        subtitle: "This will help us personalize your invoices",
                        centerTitle: true,
                      ),

                      // Responsive spacing
                      SizedBox(
                        height: isSmallScreen
                            ? constraints.maxHeight * 0.06
                            : isLargeScreen
                                ? constraints.maxHeight * 0.12
                                : constraints.maxHeight * 0.08,
                      ),

                      // Business name input with responsive width
                      Container(
                        width: screenWidth > 600
                            ? 400 // Fixed width for larger screens
                            : double.infinity, // Full width for mobile
                        child: AppTextField(
                          controller: _controller,
                          labelText: "Business Name",
                          hintText: "Enter your business name",
                          prefixIcon: Icons.business_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a business name";
                            }
                            if (value.length < 3) {
                              return "Business name must be at least 3 characters";
                            }
                            return null;
                          },
                        ),
                      ),

                      // Flexible spacing before buttons
                      SizedBox(
                        height: isSmallScreen
                            ? constraints.maxHeight * 0.08
                            : constraints.maxHeight * 0.15,
                      ),

                      // Bottom action buttons with responsive width
                      Container(
                        width: screenWidth > 600
                            ? 400 // Fixed width for larger screens
                            : double.infinity, // Full width for mobile
                        child: BottomActionBar(
                          primaryButtonText: "Continue",
                          onPrimaryPressed: _continue,
                          onSkipPressed: () =>
                              Navigator.pushNamed(context, "/uploadlogo"),
                        ),
                      ),

                      // Bottom spacing to ensure buttons are not at the very bottom
                      SizedBox(height: AppSpacing.lg),
                    ],
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
