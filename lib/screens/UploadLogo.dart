import 'package:flutter/material.dart';
import 'package:invoiceapp/components/ButtonComponent.dart';
import 'package:invoiceapp/components/SkipButton.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';

class UploadLogoScreen extends StatelessWidget {
  const UploadLogoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text('Upload Your\nBusiness Logo',
                  textAlign: TextAlign.center, style: primaryTextStyle),
              const SizedBox(height: 30),
              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.upload_file,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              Buttoncomponent(
                  text: "Continue",
                  onPressed: () {
                    Navigator.pushNamed(context, "/businessName");
                  },
                  color: primaryColor,
                  textStyle: buttonTextStyle),
              const SizedBox(height: 5),
              SkipButton(onTap: () {
                Navigator.pushNamed(context, "/businessName");
              }),
            ],
          ),
        ),
      ),
    );
  }
}
