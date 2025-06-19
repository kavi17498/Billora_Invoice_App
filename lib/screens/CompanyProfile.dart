import 'package:flutter/material.dart';
import 'package:invoiceapp/components/ButtonComponent.dart';
import 'package:invoiceapp/components/CustomTextField.dart';
import 'package:invoiceapp/components/SkipButton.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/services/database_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController address3Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController EmailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  void _saveProfile() async {
    String fullAddress =
        "${address1Controller.text}, ${address2Controller.text}, ${address3Controller.text}, ${cityController.text}";

    try {
      await DatabaseService.instance.updateUserDetails(
        userId: 1, // Only one user
        address: fullAddress,
        phone: phoneController.text,
        website: websiteController.text,
        email: EmailController.text,
      );

      Navigator.pushNamed(context, "/paymentinstructions");
    } catch (e) {
      print("Failed to update profile: $e");
      // You could show a snackbar or alert here for the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // This is true by default, but it's good to be explicit
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Complete\nYour Profile',
                style: primaryTextStyle,
              ),
              const SizedBox(height: 30),
              CustomTextField(
                  hintText: "Address Line 1 ....",
                  controller: address1Controller),
              const SizedBox(height: 15),
              CustomTextField(
                  hintText: "Address Line 2 ....",
                  controller: address2Controller),
              const SizedBox(height: 15),
              CustomTextField(
                  hintText: "Address Line 3....",
                  controller: address3Controller),
              const SizedBox(height: 15),
              CustomTextField(
                  hintText: "City ....", controller: cityController),
              const SizedBox(height: 15),
              CustomTextField(
                  hintText: "Email ....", controller: EmailController),
              const SizedBox(height: 15),
              CustomTextField(
                hintText: "Telephone No ....",
                keyboardType: TextInputType.phone,
                controller: phoneController,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                  hintText: "Website ....", controller: websiteController),
              const SizedBox(height: 20),
              Buttoncomponent(
                text: "Continue",
                onPressed: _saveProfile,
                color: primaryColor,
                textStyle: buttonTextStyle,
              ),
              SkipButton(onTap: () {
                Navigator.pushNamed(context, "/paymentinstructions");
              }),
              const SizedBox(
                  height:
                      30), // extra space at bottom to avoid last field being hidden
            ],
          ),
        ),
      ),
    );
  }
}
