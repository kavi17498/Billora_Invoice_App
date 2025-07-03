import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/Invoicespage.dart';
import 'package:invoiceapp/screens/client/add_client.dart';
import 'package:invoiceapp/screens/client/client_list.dart';
import 'package:invoiceapp/screens/Analyze.dart';
import 'package:invoiceapp/screens/invoiceGen/dialogbox.dart';
import 'package:invoiceapp/screens/items/create_item_page.dart';
import 'package:invoiceapp/screens/items/item_List.dart';
import 'package:invoiceapp/screens/settings.dart';
import 'package:invoiceapp/services/onboarding_service.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  // Global keys for tutorial targets
  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _bottomNavKey = GlobalKey();

  TutorialCoachMark? tutorialCoachMark;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _selectedIndex = args;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAndShowTutorial();
  }

  Future<void> _checkAndShowTutorial() async {
    // Check if user has completed onboarding but not dashboard tutorial
    final hasSeenOnboarding = await OnboardingService.hasSeenOnboarding();
    final hasSeenDashboardTutorial =
        await OnboardingService.hasSeenDashboardTutorial();

    if (hasSeenOnboarding && !hasSeenDashboardTutorial) {
      // Small delay to ensure UI is built
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        _showInteractiveTutorial();
      }
    }
  }

  void _showInteractiveTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black54,
      textSkip: "Skip Tutorial",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        // Mark dashboard tutorial as completed
        OnboardingService.setDashboardTutorialCompleted();
      },
      onSkip: () {
        // Mark dashboard tutorial as completed even if skipped
        OnboardingService.setDashboardTutorialCompleted();
        return true;
      },
    );

    tutorialCoachMark?.show(context: context);
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    // First: Show the bottom navigation and explain the workflow
    targets.add(
      TargetFocus(
        identify: "bottom_nav",
        keyTarget: _bottomNavKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome to Your Dashboard!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Let's walk through the main sections step by step:",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "1️⃣ First, we'll add your clients\n2️⃣ Then, add your products/services\n3️⃣ Finally, create invoices\n\nThis bottom bar helps you navigate between sections.",
                      style: TextStyle(color: Colors.black87, height: 1.4),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to clients tab first
                        setState(() {
                          _selectedIndex = 2; // Clients tab
                        });
                        controller.next();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4D7CFE),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Let's Start with Clients"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    // Second: Explain clients section
    targets.add(
      TargetFocus(
        identify: "clients_section",
        keyTarget: _fabKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "👥 Step 1: Add Your Clients",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Before creating invoices, you need to add your clients. Click this + button to add a new client with their contact information, address, and payment details.",
                      style: TextStyle(color: Colors.black87, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "💡 Tip: Add all your regular clients first - this makes invoice creation much faster later!",
                      style: TextStyle(
                          color: Colors.blue, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to items tab next
                        setState(() {
                          _selectedIndex = 3; // Items tab
                        });
                        controller.next();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4D7CFE),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Next: Add Products/Services"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    // Third: Explain items section
    targets.add(
      TargetFocus(
        identify: "items_section",
        keyTarget: _fabKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "📦 Step 2: Add Your Products/Services",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Now add the items you sell - products, services, or anything you invoice for. Set their prices and descriptions here.",
                      style: TextStyle(color: Colors.black87, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "💡 Examples: 'Web Design Service - \$500', 'Product Name - \$25', 'Consulting Hour - \$100'",
                      style: TextStyle(
                          color: Colors.green, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to invoices tab next
                        setState(() {
                          _selectedIndex = 0; // Invoices tab
                        });
                        controller.next();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4D7CFE),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Next: Create Invoices"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    // Fourth: Explain invoices section
    targets.add(
      TargetFocus(
        identify: "invoices_section",
        keyTarget: _fabKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "📋 Step 3: Create Your Invoices",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Now you're ready to create professional invoices! Select your client, add your items, and generate beautiful PDF invoices to send.",
                      style: TextStyle(color: Colors.black87, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "✨ Since you've already added clients and items, creating invoices is now super quick and easy!",
                      style: TextStyle(
                          color: Colors.purple, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () => controller.next(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4D7CFE),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Show Me Analytics"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    // Fifth: Explain analytics section
    targets.add(
      TargetFocus(
        identify: "analytics_section",
        keyTarget: _bottomNavKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "📊 Bonus: Track Your Business",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "The Analytics tab shows charts and reports about your business performance. Track revenue, see your best clients, and monitor growth over time.",
                      style: TextStyle(color: Colors.black87, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "⚙️ Don't forget the Settings tab to customize your business profile!",
                      style: TextStyle(
                          color: Colors.orange, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () => controller.next(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Perfect! Let's Get Started"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }

  final List<Widget> _pages = const [
    InvoiceListPage(),
    FinancialAnalysisPage(),
    ClientListScreen(),
    ItemListPage(),
    SettingsPage(),
  ];

  final List<String> _titles = const [
    "Invoices",
    "Financial Analysis",
    "Clients",
    "Items",
    "Settings",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Define FAB based on selected page
  Widget? _buildFloatingActionButton() {
    switch (_selectedIndex) {
      case 0: // Invoices
        return FloatingActionButton(
          key: _fabKey,
          heroTag: "create_invoice",
          onPressed: () {
            showInvoiceDialog(context);
          },
          backgroundColor: const Color(0xFF4D7CFE),
          child: const Icon(Icons.add),
        );
      case 1: // Estimations
        return FloatingActionButton(
          key: _fabKey,
          heroTag: "create_estimation",
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Create estimation")),
            );
          },
          backgroundColor: const Color(0xFF4D7CFE),
          child: const Icon(Icons.add),
        );
      case 2: // Clients
        return FloatingActionButton(
          key: _fabKey,
          heroTag: "add_client",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddClientScreen()),
            );
          },
          backgroundColor: const Color(0xFF4D7CFE),
          child: const Icon(Icons.person_add),
        );
      case 3: // Items
        return FloatingActionButton(
          key: _fabKey,
          heroTag: "add_item",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateItemPage()),
            );
          },
          backgroundColor: const Color(0xFF4D7CFE),
          child: const Icon(Icons.add_box),
        );
      case 4: // Profile
        return null; // No FAB on profile screen
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        key: _bottomNavKey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF4D7CFE),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Invoices'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart), label: 'Analyze'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Items'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
