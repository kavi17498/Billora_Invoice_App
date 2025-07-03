import 'package:flutter/material.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';

enum AppCardVariant { elevated, outlined, filled }

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final AppCardVariant variant;
  final VoidCallback? onTap;
  final bool interactive;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.variant = AppCardVariant.elevated,
    this.onTap,
    this.interactive = false,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDuration.medium,
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: _getBaseElevation(),
      end: _getHoverElevation(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.standard,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.standard,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _getBaseElevation() {
    if (widget.elevation != null) return widget.elevation!;

    switch (widget.variant) {
      case AppCardVariant.elevated:
        return AppSizing.cardElevation;
      case AppCardVariant.outlined:
      case AppCardVariant.filled:
        return 0;
    }
  }

  double _getHoverElevation() {
    if (!widget.interactive) return _getBaseElevation();

    switch (widget.variant) {
      case AppCardVariant.elevated:
        return AppSizing.cardElevationHover;
      case AppCardVariant.outlined:
      case AppCardVariant.filled:
        return AppSizing.cardElevation;
    }
  }

  Color _getBackgroundColor() {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    switch (widget.variant) {
      case AppCardVariant.elevated:
      case AppCardVariant.outlined:
        return AppColors.surface;
      case AppCardVariant.filled:
        return AppColors.surfaceVariant;
    }
  }

  BorderSide? _getBorderSide() {
    switch (widget.variant) {
      case AppCardVariant.elevated:
      case AppCardVariant.filled:
        return null;
      case AppCardVariant.outlined:
        return const BorderSide(color: AppColors.border, width: 1);
    }
  }

  void _onHover(bool isHovered) {
    if (!widget.interactive) return;

    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget card = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.interactive ? _scaleAnimation.value : 1.0,
          child: Container(
            margin: widget.margin,
            child: Material(
              elevation: _elevationAnimation.value,
              shadowColor: AppColors.shadow,
              borderRadius: widget.borderRadius ?? AppSizing.borderRadiusMD,
              color: _getBackgroundColor(),
              child: Container(
                padding: widget.padding ?? AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius ?? AppSizing.borderRadiusMD,
                  border: _getBorderSide() != null
                      ? Border.all(
                          color: _getBorderSide()!.color,
                          width: _getBorderSide()!.width,
                        )
                      : null,
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );

    if (widget.onTap != null || widget.interactive) {
      return MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: card,
        ),
      );
    }

    return card;
  }
}
