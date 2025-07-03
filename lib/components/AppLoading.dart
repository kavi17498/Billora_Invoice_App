import 'package:flutter/material.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';

enum AppLoadingSize { small, medium, large }

class AppLoading extends StatelessWidget {
  final AppLoadingSize size;
  final Color? color;
  final String? message;
  final bool overlay;

  const AppLoading({
    super.key,
    this.size = AppLoadingSize.medium,
    this.color,
    this.message,
    this.overlay = false,
  });

  double _getSize() {
    switch (size) {
      case AppLoadingSize.small:
        return 20;
      case AppLoadingSize.medium:
        return 32;
      case AppLoadingSize.large:
        return 48;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _getSize(),
          height: _getSize(),
          child: CircularProgressIndicator(
            color: color ?? AppColors.primary,
            strokeWidth: size == AppLoadingSize.small ? 2 : 3,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            message!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (overlay) {
      return Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: AppSpacing.paddingLG,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSizing.borderRadiusMD,
            ),
            child: loading,
          ),
        ),
      );
    }

    return loading;
  }
}

class AppLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;

  const AppLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          AppLoading(
            overlay: true,
            message: loadingMessage,
          ),
      ],
    );
  }
}
