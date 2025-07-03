import 'package:flutter/material.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';
import 'package:invoiceapp/components/ButtonComponent.dart';
import 'package:lottie/lottie.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo/title
              Text(
                "Billora",
                style: AppTextStyles.display1.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Lottie animation
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Lottie.asset(
                  "assets/lottie/k.json",
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              // Subtitle
              Text(
                "Invoice Maker\nSmarter Billing. Simpler Business",
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl * 2),

              // Get Started button
              AppButton(
                text: "Get Started",
                onPressed: () {
                  Navigator.pushNamed(context, "/businessName");
                },
                size: AppButtonSize.large,
                fullWidth: true,
                icon: Icons.arrow_forward_rounded,
                iconRight: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
