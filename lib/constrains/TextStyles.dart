import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:invoiceapp/constrains/Colors.dart';

class AppTextStyles {
  // Base font family
  static String get fontFamily => GoogleFonts.poppins().fontFamily!;

  // Display styles (largest)
  static TextStyle display1 = GoogleFonts.poppins(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle display2 = GoogleFonts.poppins(
    fontSize: 44,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Heading styles
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle h3 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle h4 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle h5 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle h6 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body text styles
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Label styles
  static TextStyle labelLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle labelMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle labelSmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Button styles
  static TextStyle buttonLarge = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  static TextStyle buttonMedium = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  static TextStyle buttonSmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    height: 1.2,
  );

  // Caption and overline
  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.3,
  );

  static TextStyle overline = GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    height: 1.3,
    letterSpacing: 0.5,
  );
}

// Backward compatibility - gradually remove these
TextStyle primaryTextStyle =
    AppTextStyles.h1.copyWith(color: AppColors.primary);
TextStyle subTextStyle =
    AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary);
TextStyle bigtext = AppTextStyles.display1.copyWith(color: AppColors.primary);
TextStyle buttonTextStyle = AppTextStyles.buttonMedium;
TextStyle heading = AppTextStyles.h5;
