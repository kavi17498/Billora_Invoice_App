import 'package:flutter/material.dart';

class Invoicespage extends StatefulWidget {
  const Invoicespage({super.key});

  @override
  State<Invoicespage> createState() => _InvoicespageState();
}

class _InvoicespageState extends State<Invoicespage> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
      "Invoices Page",
      style: TextStyle(fontSize: 20, color: Colors.grey),
    ));
  }
}
