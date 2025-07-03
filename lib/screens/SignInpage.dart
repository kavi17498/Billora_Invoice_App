import 'package:flutter/material.dart';
import 'package:invoiceapp/components/ButtonComponent.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';
import 'package:lottie/lottie.dart';

class SignInpage extends StatelessWidget {
  const SignInpage({super.key});

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
              // Login title
              Text(
                "Login to your\nAccount",
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
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
              SizedBox(height: AppSpacing.xl * 2),

              // Login button
              AppButton(
                text: "Login",
                onPressed: () {
                  Navigator.pushNamed(context, "/businessName");
                },
                size: AppButtonSize.large,
                fullWidth: true,
                icon: Icons.login_rounded,
                iconRight: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
