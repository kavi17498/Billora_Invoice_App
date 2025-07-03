import 'package:flutter/material.dart';
import 'package:invoiceapp/services/database_service.dart';
import 'package:invoiceapp/services/onboarding_service.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    final dbService = DatabaseService.instance;
    final userExists = await dbService.doesUserExist();
    final hasSeenOnboarding = await OnboardingService.hasSeenOnboarding();

    if (!mounted) return;

    if (userExists) {
      // User exists, check if they've seen the tour
      if (!hasSeenOnboarding) {
        Navigator.pushReplacementNamed(context, "/app-tour");
      } else {
        Navigator.pushReplacementNamed(context, "/dashboard");
      }
    } else {
      Navigator.pushReplacementNamed(context, "/welcome");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
