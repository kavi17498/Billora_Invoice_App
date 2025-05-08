import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/Invoicespage.dart';
import 'package:invoiceapp/screens/client/add_client.dart';
import 'package:invoiceapp/screens/client/client_list.dart';
import 'package:invoiceapp/screens/Analyze.dart';
import 'package:invoiceapp/screens/invoiceGen/dialogbox.dart';
import 'package:invoiceapp/screens/items/create_item_page.dart';
import 'package:invoiceapp/screens/items/item_List.dart';

import 'package:invoiceapp/screens/settings.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _selectedIndex = args;
    }
  }

  final List<Widget> _pages = const [
    InvoiceListPage(),
    Analyzepage(),
    ClientListScreen(),
    ItemListPage(),
    SettingsPage(),
  ];

  final List<String> _titles = const [
    "Invoices",
    "Analyze",
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
          heroTag: "create_invoice",
          onPressed: () {
            showInvoiceDialog(context);
          },
          backgroundColor: const Color(0xFF4D7CFE),
          child: const Icon(Icons.add),
        );
      case 1: // Estimations
        return FloatingActionButton(
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
