import 'package:flutter/material.dart';
import 'package:invoiceapp/services/database_service.dart';

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

    if (!mounted) return;

    if (userExists) {
      Navigator.pushReplacementNamed(context, "/dashboard");
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
