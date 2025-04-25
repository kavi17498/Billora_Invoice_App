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
            SizedBox(
              height: 20,
            ),
            Image.asset(
              "assets/images/welcome.png",
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
