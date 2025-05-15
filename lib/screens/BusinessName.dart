import 'package:flutter/material.dart';
import 'package:invoiceapp/components/ButtonComponent.dart';
import 'package:invoiceapp/components/SkipButton.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/services/database_service.dart';

class Businessname extends StatefulWidget {
  const Businessname({super.key});

  @override
  State<Businessname> createState() => _BusinessnameState();
}

class _BusinessnameState extends State<Businessname> {
  String? _businessName = null;

  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "Enter your Business Name",
                  style: primaryTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: TextField(
                  onChanged: (value) {
                    _businessName = value;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    hintText: "Business Name",
                    hintStyle: subTextStyle,
                  ),
                ),
              ),
              Buttoncomponent(
                  text: "Continue",
                  onPressed: () {
                    if (_businessName == null || _businessName!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a business name ..!"),
                        ),
                      );
                      return;
                    }
                    if (_businessName!.length < 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Business name must be at least 3 characters"),
                        ),
                      );
                      return;
                    }

                    _databaseService.insertUser(
                      _businessName!,
                    );
                    Navigator.pushNamed(context, "/uploadlogo");
                  },
                  color: primaryColor,
                  textStyle: buttonTextStyle),
              const SizedBox(
                height: 5,
              ),
              SkipButton(onTap: () {
                Navigator.pushNamed(context, "/uploadlogo");
              }),
            ],
          ),
        ),
      ),
    );
  }
}
