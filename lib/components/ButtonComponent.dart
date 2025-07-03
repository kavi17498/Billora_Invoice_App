import 'package:flutter/material.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';

enum AppButtonSize { small, medium, large }

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  success,
  warning,
  error
}

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool iconRight;
  final bool loading;
  final bool fullWidth;
  final EdgeInsets? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.iconRight = false,
    this.loading = false,
    this.fullWidth = false,
    this.padding,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDuration.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  ButtonStyle get _buttonStyle {
    final isEnabled = widget.onPressed != null && !widget.loading;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled ? AppColors.primary : AppColors.textTertiary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.textTertiary,
          disabledForegroundColor: Colors.white,
          elevation: isEnabled ? 2 : 0,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(borderRadius: AppSizing.borderRadiusMD),
          padding: _getPadding(),
          minimumSize: Size(0, _getHeight()),
        );

      case AppButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled ? AppColors.secondary : AppColors.textTertiary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.textTertiary,
          disabledForegroundColor: Colors.white,
          elevation: isEnabled ? 2 : 0,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(borderRadius: AppSizing.borderRadiusMD),
          padding: _getPadding(),
          minimumSize: Size(0, _getHeight()),
        );

      case AppButtonVariant.outline:
        return OutlinedButton.styleFrom(
          foregroundColor:
              isEnabled ? AppColors.primary : AppColors.textTertiary,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.textTertiary,
          side: BorderSide(
            color: isEnabled ? AppColors.primary : AppColors.textTertiary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppSizing.borderRadiusMD),
          padding: _getPadding(),
          minimumSize: Size(0, _getHeight()),
        );

      case AppButtonVariant.ghost:
        return TextButton.styleFrom(
          foregroundColor:
              isEnabled ? AppColors.primary : AppColors.textTertiary,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.textTertiary,
          shape: RoundedRectangleBorder(borderRadius: AppSizing.borderRadiusMD),
          padding: _getPadding(),
          minimumSize: Size(0, _getHeight()),
        );

      case AppButtonVariant.success:
        return ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled ? AppColors.success : AppColors.textTertiary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.textTertiary,
          disabledForegroundColor: Colors.white,
          elevation: isEnabled ? 2 : 0,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(borderRadius: AppSizing.borderRadiusMD),
          padding: _getPadding(),
          minimumSize: Size(0, _getHeight()),
        );

      case AppButtonVariant.warning:
        return ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled ? AppColors.warning : AppColors.textTertiary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.textTertiary,
          disabledForegroundColor: Colors.white,
          elevation: isEnabled ? 2 : 0,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(borderRadius: AppSizing.borderRadiusMD),
          padding: _getPadding(),
          minimumSize: Size(0, _getHeight()),
        );

      case AppButtonVariant.error:
        return ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.error : AppColors.textTertiary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.textTertiary,
          disabledForegroundColor: Colors.white,
          elevation: isEnabled ? 2 : 0,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(borderRadius: AppSizing.borderRadiusMD),
          padding: _getPadding(),
          minimumSize: Size(0, _getHeight()),
        );
    }
  }

  EdgeInsets _getPadding() {
    if (widget.padding != null) return widget.padding!;

    switch (widget.size) {
      case AppButtonSize.small:
        return AppSpacing.paddingHorizontalMD;
      case AppButtonSize.medium:
        return AppSpacing.paddingHorizontalLG;
      case AppButtonSize.large:
        return AppSpacing.paddingHorizontalXL;
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case AppButtonSize.small:
        return AppSizing.buttonHeightSmall;
      case AppButtonSize.medium:
        return AppSizing.buttonHeight;
      case AppButtonSize.large:
        return AppSizing.buttonHeightLarge;
    }
  }

  TextStyle _getTextStyle() {
    Color textColor = Colors.white;
    if (widget.variant == AppButtonVariant.outline ||
        widget.variant == AppButtonVariant.ghost) {
      textColor =
          widget.onPressed != null ? AppColors.primary : AppColors.textTertiary;
    }

    switch (widget.size) {
      case AppButtonSize.small:
        return AppTextStyles.buttonSmall.copyWith(color: textColor);
      case AppButtonSize.medium:
        return AppTextStyles.buttonMedium.copyWith(color: textColor);
      case AppButtonSize.large:
        return AppTextStyles.buttonLarge.copyWith(color: textColor);
    }
  }

  Widget _buildButtonContent() {
    if (widget.loading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.variant == AppButtonVariant.outline ||
                    widget.variant == AppButtonVariant.ghost
                ? AppColors.primary
                : Colors.white,
          ),
        ),
      );
    }

    final List<Widget> children = [];

    if (widget.icon != null && !widget.iconRight) {
      children.add(Icon(widget.icon, size: AppSizing.iconSize));
      children.add(const SizedBox(width: AppSpacing.sm));
    }

    children.add(Text(widget.text, style: _getTextStyle()));

    if (widget.icon != null && widget.iconRight) {
      children.add(const SizedBox(width: AppSpacing.sm));
      children.add(Icon(widget.icon, size: AppSizing.iconSize));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget button;

    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
      case AppButtonVariant.success:
      case AppButtonVariant.warning:
      case AppButtonVariant.error:
        button = ElevatedButton(
          onPressed: widget.onPressed,
          style: _buttonStyle,
          child: _buildButtonContent(),
        );
        break;
      case AppButtonVariant.outline:
        button = OutlinedButton(
          onPressed: widget.onPressed,
          style: _buttonStyle,
          child: _buildButtonContent(),
        );
        break;
      case AppButtonVariant.ghost:
        button = TextButton(
          onPressed: widget.onPressed,
          style: _buttonStyle,
          child: _buildButtonContent(),
        );
        break;
    }

    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: button,
          );
        },
      ),
    );
  }
}

// Backward compatibility wrapper
class Buttoncomponent extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final TextStyle textStyle;

  const Buttoncomponent({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
      fullWidth: true,
    );
  }
}
