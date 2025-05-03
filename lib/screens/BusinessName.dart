import 'package:flutter/material.dart';
import 'package:invoiceapp/components/ButtonComponent.dart';
import 'package:invoiceapp/components/SkipButton.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Colors.dart';

class Businessname extends StatelessWidget {
  const Businessname({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
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
