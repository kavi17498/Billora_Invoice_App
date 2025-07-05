import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/settings/template_settings.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildSettingsCard(
            context,
            icon: Icons.person_outline,
            title: "Profile Settings",
            subtitle: "Manage your company profile and details",
            onTap: () => Navigator.pushNamed(context, "/prfile"),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSettingsCard(
            context,
            icon: Icons.description_outlined,
            title: "Invoice Templates",
            subtitle: "Customize invoice layouts and colors",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TemplateSettingsScreen(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSettingsCard(
            context,
            icon: Icons.attach_money,
            title: "Currency Settings",
            subtitle: "Select your preferred currency for invoices",
            onTap: () => Navigator.pushNamed(context, "/currency-settings"),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSettingsCard(
            context,
            icon: Icons.palette_outlined,
            title: "Change Theme",
            subtitle: "Coming soon - App theme customization",
            onTap: () => Navigator.pushNamed(context, "/commingsoon"),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizing.radiusLG),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.lg),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizing.radiusMD),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.h6.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
