import 'package:flutter/material.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/services/onboarding_service.dart';

class AppTourScreen extends StatefulWidget {
  const AppTourScreen({super.key});

  @override
  State<AppTourScreen> createState() => _AppTourScreenState();
}

class _AppTourScreenState extends State<AppTourScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TourPage> _pages = [
    TourPage(
      title: "Welcome to Billora",
      description:
          "Your complete invoice management solution. Let's explore what you can do!",
      icon: Icons.receipt_long,
      color: Color(0xFF4D7CFE),
    ),
    TourPage(
      title: "Create & Manage Invoices",
      description:
          "Create professional invoices, track payments, and manage your billing. Generate PDF invoices and send them to clients easily.",
      icon: Icons.receipt_outlined,
      color: Color(0xFF10B981),
    ),
    TourPage(
      title: "Business Analytics",
      description:
          "View detailed charts and reports about your business performance. Track revenue, top clients, and financial trends over time.",
      icon: Icons.analytics_outlined,
      color: Color(0xFFEF4444),
    ),
    TourPage(
      title: "Client Management",
      description:
          "Keep track of all your clients in one place. Store contact information, addresses, and payment details for easy invoice creation.",
      icon: Icons.people_outline,
      color: Color(0xFF8B5CF6),
    ),
    TourPage(
      title: "Items Catalog",
      description:
          "Manage your items catalog - everything you sell or bill for. Set default prices and descriptions for quick invoice creation and consistent billing.",
      icon: Icons.inventory_2_outlined,
      color: Color(0xFFF59E0B),
    ),
    TourPage(
      title: "Settings & Profile",
      description:
          "Customize your business profile, manage company information, and configure app settings to suit your needs.",
      icon: Icons.settings_outlined,
      color: Color(0xFF6366F1),
    ),
    TourPage(
      title: "You're All Set!",
      description:
          "Ready to start managing your invoices? Use the bottom navigation to switch between different sections and the + button to create new items.",
      icon: Icons.rocket_launch_outlined,
      color: Color(0xFF4D7CFE),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _skipTour,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildTourPage(_pages[index]);
                },
              ),
            ),
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? primaryColor
                        : secondaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back_ios,
                              color: secondaryColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Previous',
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(),

                  // Next/Get Started button
                  ElevatedButton(
                    onPressed: _currentPage == _pages.length - 1
                        ? _finishTour
                        : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == _pages.length - 1
                              ? Icons.rocket_launch
                              : Icons.arrow_forward_ios,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourPage(TourPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: secondaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipTour() {
    _finishTour();
  }

  void _finishTour() async {
    await OnboardingService.setOnboardingCompleted();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class TourPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  TourPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
