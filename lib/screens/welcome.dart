import 'package:flutter/material.dart';
import 'package:invoiceapp/constrains/Colors.dart';
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
            Text("Billora", style: bigtext),
            SizedBox(
              height: 20,
            ),
            Lottie.asset(
              "assets/lottie/k.json",
              width: 300,
              height: 300,
              fit: BoxFit.fill,
            ),
            SizedBox(
              height: 40,
            ),
            Center(
              child: Text(
                "Invoice Maker \n Smarter Billing. Simpler Business",
                style: subTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/businessName");
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: primaryColor,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Get Started",
                  style: buttonTextStyle,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
