import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constrains/TextStyles.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to \nInvoice App", style: primaryTextStyle),
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
