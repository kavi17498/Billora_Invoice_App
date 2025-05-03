import 'package:flutter/material.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';

class SkipButton extends StatelessWidget {
  final VoidCallback onTap;

  const SkipButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width * 0.5,
        alignment: Alignment.center,
        child: Text(
          "Skip",
          style: buttonTextStyle.copyWith(
            color: primaryColor,
            decoration: TextDecoration.underline, // 👈 underline added here
          ),
        ),
      ),
    );
  }
}
