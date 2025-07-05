import 'package:flutter/material.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';
import 'package:invoiceapp/components/CustomTextField.dart';
import 'package:invoiceapp/components/ButtonComponent.dart';
import 'package:invoiceapp/components/SkipButton.dart';
import 'package:invoiceapp/components/AppAppBar.dart';
import 'package:invoiceapp/components/ScreenHeader.dart';
import 'package:invoiceapp/services/database_service.dart';

class PaymentInstructionsSetup extends StatefulWidget {
  const PaymentInstructionsSetup({super.key});

  @override
  State<PaymentInstructionsSetup> createState() =>
      _PaymentInstructionsSetupState();
}

class _PaymentInstructionsSetupState extends State<PaymentInstructionsSetup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _paymentInstructionsController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _paymentInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _savePaymentInstructions() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseService.instance.updateallUserDetails(
        userId: 1,
        note: _paymentInstructionsController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment instructions saved successfully!',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pushNamed(context, "/dashboard");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save payment instructions. Please try again.',
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

  void _skipPaymentInstructions() {
    Navigator.pushNamed(context, "/dashboard");
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenSize.height < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Payment Instructions',
        showBackButton: true,
        actions: [
          SkipButton(onTap: _skipPaymentInstructions),
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
                    vertical: isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Header section
                        const ScreenHeader(
                          title: 'Payment Instructions',
                          subtitle:
                              'Add payment details that will appear on your invoices to help clients pay you easily',
                        ),
                        SizedBox(height: AppSpacing.xl),

                        // Instruction card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primary,
                                size: 32,
                              ),
                              SizedBox(height: AppSpacing.sm),
                              Text(
                                'Examples of payment instructions:',
                                style: AppTextStyles.h6.copyWith(
                                  color: AppColors.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppSpacing.sm),
                              Text(
                                '• Bank account details\n• PayPal email address\n• UPI ID or QR code info\n• Cash payment terms\n• Credit card processing info',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),

                        // Form section
                        Container(
                          width: screenWidth > 600 ? 500 : double.infinity,
                          child: Column(
                            children: [
                              AppTextField(
                                controller: _paymentInstructionsController,
                                labelText: 'Payment Instructions',
                                hintText:
                                    'Enter your payment details here...\n\nExample:\nBank: ABC Bank\nAccount: 1234567890\nIFSC: ABCD0123456\n\nOr\n\nPayPal: your.email@domain.com\nUPI: yourname@paytm',
                                prefixIcon: Icons.payment_rounded,
                                maxLines: 8,
                                validator: (value) {
                                  // Optional field, so no validation required
                                  return null;
                                },
                              ),
                              SizedBox(height: AppSpacing.sm),
                              Text(
                                'These instructions will appear at the bottom of every invoice you generate.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSpacing.xl * 2),

                        // Action buttons
                        Container(
                          width: screenWidth > 600 ? 500 : double.infinity,
                          child: Column(
                            children: [
                              AppButton(
                                text: 'Save Payment Instructions',
                                onPressed: _isLoading
                                    ? null
                                    : _savePaymentInstructions,
                                loading: _isLoading,
                                size: AppButtonSize.large,
                                fullWidth: true,
                                icon: Icons.save_rounded,
                                iconRight: true,
                              ),
                              SizedBox(height: AppSpacing.md),
                              AppButton(
                                text: 'Skip for Now',
                                onPressed: _skipPaymentInstructions,
                                variant: AppButtonVariant.outline,
                                size: AppButtonSize.large,
                                fullWidth: true,
                                icon: Icons.skip_next_rounded,
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
