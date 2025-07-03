import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';

enum AppTextFieldSize { small, medium, large }

enum AppTextFieldVariant { outline, filled, underline }

class AppTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final VoidCallback? onSuffixIconTap;
  final AppTextFieldSize size;
  final AppTextFieldVariant variant;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.onSuffixIconTap,
    this.size = AppTextFieldSize.medium,
    this.variant = AppTextFieldVariant.outline,
    this.inputFormatters,
    this.focusNode,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animationController = AnimationController(
      duration: AppDuration.fast,
      vsync: this,
    );
    _borderColorAnimation = ColorTween(
      begin: AppColors.border,
      end: AppColors.primary,
    ).animate(_animationController);

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  EdgeInsets _getContentPadding() {
    switch (widget.size) {
      case AppTextFieldSize.small:
        return const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm);
      case AppTextFieldSize.medium:
        return const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md);
      case AppTextFieldSize.large:
        return const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.lg);
    }
  }

  double _getBorderRadius() {
    switch (widget.variant) {
      case AppTextFieldVariant.outline:
      case AppTextFieldVariant.filled:
        return AppSizing.radiusMD;
      case AppTextFieldVariant.underline:
        return 0;
    }
  }

  InputDecoration _buildDecoration() {
    final hasError = widget.errorText != null;

    switch (widget.variant) {
      case AppTextFieldVariant.outline:
        return InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          helperText: widget.helperText,
          errorText: widget.errorText,
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon,
                  color:
                      _isFocused ? AppColors.primary : AppColors.textSecondary)
              : null,
          prefix: widget.prefix,
          suffixIcon: widget.suffixIcon != null
              ? GestureDetector(
                  onTap: widget.onSuffixIconTap,
                  child: Icon(widget.suffixIcon,
                      color: _isFocused
                          ? AppColors.primary
                          : AppColors.textSecondary),
                )
              : null,
          suffix: widget.suffix,
          contentPadding: _getContentPadding(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          labelStyle: AppTextStyles.labelMedium.copyWith(
            color: hasError
                ? AppColors.error
                : _isFocused
                    ? AppColors.primary
                    : AppColors.textSecondary,
          ),
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          helperStyle: AppTextStyles.bodySmall,
          errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
        );

      case AppTextFieldVariant.filled:
        return InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          helperText: widget.helperText,
          errorText: widget.errorText,
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon,
                  color:
                      _isFocused ? AppColors.primary : AppColors.textSecondary)
              : null,
          prefix: widget.prefix,
          suffixIcon: widget.suffixIcon != null
              ? GestureDetector(
                  onTap: widget.onSuffixIconTap,
                  child: Icon(widget.suffixIcon,
                      color: _isFocused
                          ? AppColors.primary
                          : AppColors.textSecondary),
                )
              : null,
          suffix: widget.suffix,
          contentPadding: _getContentPadding(),
          filled: true,
          fillColor: _isFocused ? AppColors.surfaceVariant : AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          labelStyle: AppTextStyles.labelMedium.copyWith(
            color: hasError
                ? AppColors.error
                : _isFocused
                    ? AppColors.primary
                    : AppColors.textSecondary,
          ),
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          helperStyle: AppTextStyles.bodySmall,
          errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
        );

      case AppTextFieldVariant.underline:
        return InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          helperText: widget.helperText,
          errorText: widget.errorText,
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon,
                  color:
                      _isFocused ? AppColors.primary : AppColors.textSecondary)
              : null,
          prefix: widget.prefix,
          suffixIcon: widget.suffixIcon != null
              ? GestureDetector(
                  onTap: widget.onSuffixIconTap,
                  child: Icon(widget.suffixIcon,
                      color: _isFocused
                          ? AppColors.primary
                          : AppColors.textSecondary),
                )
              : null,
          suffix: widget.suffix,
          contentPadding: _getContentPadding(),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          labelStyle: AppTextStyles.labelMedium.copyWith(
            color: hasError
                ? AppColors.error
                : _isFocused
                    ? AppColors.primary
                    : AppColors.textSecondary,
          ),
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          helperStyle: AppTextStyles.bodySmall,
          errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderColorAnimation,
      builder: (context, child) {
        return TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          inputFormatters: widget.inputFormatters,
          style: AppTextStyles.bodyMedium,
          decoration: _buildDecoration(),
        );
      },
    );
  }
}

// Backward compatibility wrapper
class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      hintText: hintText,
      keyboardType: keyboardType,
      controller: controller,
      variant: AppTextFieldVariant.outline,
    );
  }
}
