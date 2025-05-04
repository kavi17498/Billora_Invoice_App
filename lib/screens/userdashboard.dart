import 'package:flutter/material.dart';
import 'package:invoiceapp/screens/Invoicespage.dart';
import 'package:invoiceapp/screens/clientspage.dart';
import 'package:invoiceapp/screens/estimations.dart';
import 'package:invoiceapp/screens/invoiceGen/dialogbox.dart';
import 'package:invoiceapp/screens/itemspage.dart';
import 'package:invoiceapp/screens/settings.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    Invoicespage(),
    EstimationsPage(),
    ClientsPage(),
    ItemsPage(),
    SettingsPage(),
  ];

  final List<String> _titles = const [
    "Invoices",
    "Estimations",
    "Clients",
    "Items",
    "Settings",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showInvoiceDialog(context);
        },
        backgroundColor: const Color(0xFF4D7CFE),
        child: const Icon(Icons.add),
      ),
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
              icon: Icon(Icons.description), label: 'Estimations'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Items'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
