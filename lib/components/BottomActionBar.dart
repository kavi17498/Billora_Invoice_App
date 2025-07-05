import 'package:flutter/material.dart';
import 'package:invoiceapp/components/ButtonComponent.dart';
import 'package:invoiceapp/components/SkipButton.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';

class BottomActionBar extends StatelessWidget {
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final bool showSkipButton;
  final VoidCallback? onSkipPressed;
  final bool primaryButtonLoading;
  final bool primaryButtonEnabled;
  final IconData? primaryButtonIcon;
  final AppButtonSize primaryButtonSize;

  const BottomActionBar({
    super.key,
    required this.primaryButtonText,
    this.onPrimaryPressed,
    this.showSkipButton = true,
    this.onSkipPressed,
    this.primaryButtonLoading = false,
    this.primaryButtonEnabled = true,
    this.primaryButtonIcon,
    this.primaryButtonSize = AppButtonSize.large,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          text: primaryButtonText,
          onPressed: primaryButtonEnabled ? onPrimaryPressed : null,
          size: primaryButtonSize,
          fullWidth: true,
          loading: primaryButtonLoading,
          icon: primaryButtonIcon ?? Icons.arrow_forward_rounded,
          iconRight: true,
        ),
        if (showSkipButton && onSkipPressed != null) ...[
          SizedBox(height: isSmallScreen ? AppSpacing.xs : AppSpacing.sm),
          SkipButton(
            onTap: onSkipPressed!,
          ),
        ],
      ],
    );
  }
}
