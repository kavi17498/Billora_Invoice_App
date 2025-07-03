import 'package:flutter/material.dart';

// Modern Color Palette
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4D7CFE);
  static const Color primaryLight = Color(0xFF7BA7FF);
  static const Color primaryDark = Color(0xFF2563EB);

  // Secondary Colors
  static const Color secondary = Color(0xFF6366F1);
  static const Color secondaryLight = Color(0xFF8B5CF6);
  static const Color secondaryDark = Color(0xFF4F46E5);

  // Neutral Colors
  static const Color background = Color(0xFFFAFBFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);

  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Backward compatibility - remove these gradually
Color primaryColor = AppColors.primary;
Color secondaryColor = AppColors.textSecondary;
Color backgroundColor = AppColors.background;
Color textColor = AppColors.textPrimary;
