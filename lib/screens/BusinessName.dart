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
  String? _businessName;
  final TextEditingController _controller = TextEditingController();
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    if (_businessName == null || _businessName!.isEmpty) {
      _showError("Please enter a business name");
      return;
    }
    if (_businessName!.length < 3) {
      _showError("Business name must be at least 3 characters");
      return;
    }

    _databaseService.insertUser(_businessName!);
    Navigator.pushNamed(context, "/uploadlogo");
  }

  void _showError(String message) {
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
      ),
    );
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    const ScreenHeader(
                      title: "Enter your Business Name",
                      subtitle: "This will help us personalize your invoices",
                      centerTitle: true,
                    ),
                    SizedBox(height: AppSpacing.xl * 2),

                    // Business name input
                    AppTextField(
                      controller: _controller,
                      labelText: "Business Name",
                      hintText: "Enter your business name",
                      onChanged: (value) {
                        _businessName = value;
                      },
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
                  ],
                ),
              ),

              // Bottom action buttons
              BottomActionBar(
                primaryButtonText: "Continue",
                onPrimaryPressed: _continue,
                onSkipPressed: () =>
                    Navigator.pushNamed(context, "/uploadlogo"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
