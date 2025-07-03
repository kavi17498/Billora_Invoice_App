import 'package:flutter/material.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';
import 'package:invoiceapp/components/ButtonComponent.dart';
import 'package:invoiceapp/components/CustomTextField.dart';
import 'package:invoiceapp/components/AppCard.dart';
import 'package:invoiceapp/components/AppAppBar.dart';
import 'package:invoiceapp/components/ScreenHeader.dart';

class ComponentShowcaseScreen extends StatefulWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  State<ComponentShowcaseScreen> createState() =>
      _ComponentShowcaseScreenState();
}

class _ComponentShowcaseScreenState extends State<ComponentShowcaseScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Design System',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Typography Section
              ScreenHeader(
                title: 'Typography',
                subtitle: 'Text styles across the app',
              ),
              SizedBox(height: AppSpacing.lg),

              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Display 1', style: AppTextStyles.display1),
                    SizedBox(height: AppSpacing.sm),
                    Text('Heading 1', style: AppTextStyles.h1),
                    SizedBox(height: AppSpacing.sm),
                    Text('Heading 2', style: AppTextStyles.h2),
                    SizedBox(height: AppSpacing.sm),
                    Text('Heading 3', style: AppTextStyles.h3),
                    SizedBox(height: AppSpacing.sm),
                    Text('Body Large', style: AppTextStyles.bodyLarge),
                    SizedBox(height: AppSpacing.sm),
                    Text('Body Medium', style: AppTextStyles.bodyMedium),
                    SizedBox(height: AppSpacing.sm),
                    Text('Body Small', style: AppTextStyles.bodySmall),
                    SizedBox(height: AppSpacing.sm),
                    Text('Label Medium', style: AppTextStyles.labelMedium),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.xl),

              // Buttons Section
              Text(
                'Buttons',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              AppCard(
                child: Column(
                  children: [
                    // Primary buttons
                    AppButton(
                      text: 'Primary Large',
                      onPressed: () {},
                      size: AppButtonSize.large,
                      fullWidth: true,
                      icon: Icons.star_rounded,
                    ),
                    SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Medium',
                            onPressed: () {},
                            size: AppButtonSize.medium,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppButton(
                            text: 'Small',
                            onPressed: () {},
                            size: AppButtonSize.small,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Secondary buttons
                    AppButton(
                      text: 'Secondary',
                      onPressed: () {},
                      variant: AppButtonVariant.secondary,
                      fullWidth: true,
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Outline buttons
                    AppButton(
                      text: 'Outline',
                      onPressed: () {},
                      variant: AppButtonVariant.outline,
                      fullWidth: true,
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Success/Error buttons
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Success',
                            onPressed: () {},
                            variant: AppButtonVariant.success,
                            icon: Icons.check_rounded,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppButton(
                            text: 'Error',
                            onPressed: () {},
                            variant: AppButtonVariant.error,
                            icon: Icons.error_rounded,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Loading button
                    AppButton(
                      text: 'Loading',
                      onPressed: () {},
                      loading: true,
                      fullWidth: true,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.xl),

              // Text Fields Section
              Text(
                'Text Fields',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      controller: _textController,
                      labelText: 'Standard Field',
                      hintText: 'Enter some text',
                      prefixIcon: Icons.edit_rounded,
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _textController,
                      labelText: 'Email Field',
                      hintText: 'Enter email address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_rounded,
                      suffixIcon: Icons.verified_rounded,
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _textController,
                      labelText: 'Multiline Field',
                      hintText: 'Enter multiple lines',
                      prefixIcon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _textController,
                      labelText: 'Disabled Field',
                      hintText: 'This field is disabled',
                      enabled: false,
                      prefixIcon: Icons.lock_rounded,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.xl),

              // Colors Section
              Text(
                'Colors',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              AppCard(
                child: Column(
                  children: [
                    _buildColorRow('Primary', AppColors.primary),
                    _buildColorRow('Secondary', AppColors.secondary),
                    _buildColorRow('Success', AppColors.success),
                    _buildColorRow('Warning', AppColors.warning),
                    _buildColorRow('Error', AppColors.error),
                    _buildColorRow('Surface', AppColors.surface),
                    _buildColorRow('Background', AppColors.background),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.xl * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorRow(String name, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Text(
            name,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
