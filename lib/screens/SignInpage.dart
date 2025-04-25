import 'package:flutter/material.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:lottie/lottie.dart';

class SignInpage extends StatelessWidget {
  const SignInpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Login to your account",
              style: primaryTextStyle,
            ),
            Lottie.asset(
              "assets/lottie/k.json",
              width: 300,
              height: 300,
              fit: BoxFit.fill,
            ),
          ],
        ),
      ),
    );
  }
}
