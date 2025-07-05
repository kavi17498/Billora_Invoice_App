import "package:flutter/material.dart";
import "package:invoiceapp/Wrapper.dart";
import "package:invoiceapp/screens/BusinessName.dart";
import "package:invoiceapp/screens/CompanyProfile.dart";
import "package:invoiceapp/screens/PaymentInstructionsSetup.dart";
import "package:invoiceapp/screens/SignInpage.dart";
import "package:invoiceapp/screens/Unnecssary/Comingsoon.dart";
import "package:invoiceapp/screens/UploadLogo.dart";
import "package:invoiceapp/screens/app_tour_screen.dart";
import "package:invoiceapp/screens/client/add_client.dart";
import "package:invoiceapp/screens/client/client_list.dart";
import "package:invoiceapp/screens/items/item_List.dart";
import "package:invoiceapp/screens/profile/userdetailsscreen.dart";
import "package:invoiceapp/screens/settings/currency_settings.dart";
import "package:invoiceapp/screens/userdashboard.dart";
import "package:invoiceapp/screens/welcome.dart";
import "package:invoiceapp/constrains/Colors.dart";
import "package:invoiceapp/constrains/TextStyles.dart";

void main() {
  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Billora - Invoice Management",
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: AppTextStyles.fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          background: AppColors.background,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: AppTextStyles.buttonMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 2),
            textStyle: AppTextStyles.buttonMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.buttonMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          fillColor: AppColors.surfaceVariant,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          labelStyle: AppTextStyles.labelMedium
              .copyWith(color: AppColors.textSecondary),
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 2,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(8),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.labelSmall,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.borderLight,
          thickness: 1,
          space: 1,
        ),
      ),
      home: const Wrapper(),
      routes: {
        "/signin": (context) => const SignInpage(),
        "/businessName": (context) => const Businessname(),
        "/uploadlogo": (context) => const UploadLogoScreen(),
        "/companyinfo": (context) => const CompleteProfileScreen(),
        "/paymentinstructions": (context) => const PaymentInstructionsSetup(),
        "/dashboard": (context) => const UserDashboard(),
        "/clients": (context) => const ClientListScreen(),
        "/addclient": (context) => const AddClientScreen(),
        "/items": (context) => const ItemListPage(),
        "/prfile": (context) => const UserDetailsScreen(),
        "/currency-settings": (context) => const CurrencySettingsScreen(),
        "/welcome": (context) => const Welcome(),
        "/commingsoon": (context) => const ComingSoon(),
        "/app-tour": (context) => const AppTourScreen(),
      },
    );
  }
}
