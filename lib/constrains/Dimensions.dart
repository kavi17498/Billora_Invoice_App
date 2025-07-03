import 'package:flutter/material.dart';

class AppSpacing {
  // Padding and margin values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Common edge insets
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalMD =
      EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXL =
      EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const EdgeInsets paddingVerticalMD =
      EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG =
      EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXL =
      EdgeInsets.symmetric(vertical: xl);

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(lg, xl, lg, lg);
  static const EdgeInsets screenPaddingHorizontal =
      EdgeInsets.symmetric(horizontal: lg);
}

class AppSizing {
  // Common sizes
  static const double buttonHeight = 56.0;
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightLarge = 64.0;

  static const double inputHeight = 56.0;
  static const double inputHeightSmall = 40.0;

  static const double iconSize = 24.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeLarge = 32.0;

  static const double avatarSize = 40.0;
  static const double avatarSizeLarge = 64.0;

  static const double cardElevation = 2.0;
  static const double cardElevationHover = 8.0;

  // Border radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 999.0;

  // Common border radius
  static const BorderRadius borderRadiusXS =
      BorderRadius.all(Radius.circular(radiusXS));
  static const BorderRadius borderRadiusSM =
      BorderRadius.all(Radius.circular(radiusSM));
  static const BorderRadius borderRadiusMD =
      BorderRadius.all(Radius.circular(radiusMD));
  static const BorderRadius borderRadiusLG =
      BorderRadius.all(Radius.circular(radiusLG));
  static const BorderRadius borderRadiusXL =
      BorderRadius.all(Radius.circular(radiusXL));
}

class AppDuration {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

class AppCurves {
  static const Curve standard = Curves.easeInOut;
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve decelerated = Curves.easeOut;
  static const Curve accelerated = Curves.easeIn;
}
