import 'package:flutter/material.dart';
import 'package:invoiceapp/components/ButtonComponent.dart';
import 'package:invoiceapp/components/CustomTextField.dart';
import 'package:invoiceapp/components/SkipButton.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
// adjust the path if needed

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Complete\nYour Profile',
                  textAlign: TextAlign.left,
                  style: primaryTextStyle,
                ),
                const SizedBox(height: 30),
                const CustomTextField(hintText: "Address Line 1 ...."),
                const SizedBox(height: 15),
                const CustomTextField(hintText: "Address Line 2 ...."),
                const SizedBox(height: 15),
                const CustomTextField(hintText: "Address Line 3...."),
                const SizedBox(height: 15),
                const CustomTextField(hintText: "City ...."),
                const SizedBox(height: 15),
                const CustomTextField(hintText: "State ...."),
                const SizedBox(height: 15),
                const CustomTextField(
                  hintText: "Telephone No ....",
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                const CustomTextField(hintText: "Website ...."),
                const SizedBox(height: 20),
                Buttoncomponent(
                    text: "Continue",
                    onPressed: () {
                      Navigator.pushNamed(context, "/dashboard");
                    },
                    color: primaryColor,
                    textStyle: buttonTextStyle),
                SkipButton(onTap: () {
                  Navigator.pushNamed(context, "/dashboard");
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
