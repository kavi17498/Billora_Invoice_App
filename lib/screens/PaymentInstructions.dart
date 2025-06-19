import 'package:flutter/material.dart';
import 'package:invoiceapp/components/SkipButton.dart';

class Paymentinstructions extends StatefulWidget {
  const Paymentinstructions({super.key});

  @override
  State<Paymentinstructions> createState() => _PaymentinstructionsState();
}

class _PaymentinstructionsState extends State<Paymentinstructions> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Payment Instructions',
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          SkipButton(onTap: () {
            Navigator.pushNamed(context, "/dashboard");
          })
        ],
      ),
    );
  }
}
