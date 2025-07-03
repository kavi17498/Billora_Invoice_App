import 'package:flutter/material.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool showDivider;

  const AppAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.borderLight, width: 1),
              )
            : null,
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation! / 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: preferredSize.height - MediaQuery.of(context).padding.top,
          padding: AppSpacing.paddingHorizontalMD,
          child: Row(
            children: [
              // Leading
              if (leading != null)
                leading!
              else if (showBackButton && Navigator.canPop(context))
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: foregroundColor ?? AppColors.textPrimary,
                    size: AppSizing.iconSize,
                  ),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                ),

              // Title
              Expanded(
                child: Container(
                  alignment:
                      centerTitle ? Alignment.center : Alignment.centerLeft,
                  padding: EdgeInsets.only(
                    left: centerTitle ? 0 : AppSpacing.md,
                    right:
                        centerTitle && (actions?.isNotEmpty ?? false) ? 48 : 0,
                  ),
                  child: Text(
                    title,
                    style: AppTextStyles.h5.copyWith(
                      color: foregroundColor ?? AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),

              // Actions
              if (actions != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
