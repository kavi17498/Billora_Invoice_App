import 'package:flutter/material.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final CrossAxisAlignment alignment;
  final bool centerTitle;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.alignment = CrossAxisAlignment.start,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : alignment,
      children: [
        Text(
          title,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: centerTitle ? TextAlign.center : TextAlign.start,
        ),
        if (subtitle != null) ...[
          SizedBox(height: AppSpacing.sm),
          Text(
            subtitle!,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: centerTitle ? TextAlign.center : TextAlign.start,
          ),
        ],
        if (action != null) ...[
          SizedBox(height: AppSpacing.md),
          action!,
        ],
      ],
    );
  }
}
