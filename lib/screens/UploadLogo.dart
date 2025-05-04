import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoiceapp/services/database_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:invoiceapp/components/ButtonComponent.dart';
import 'package:invoiceapp/components/SkipButton.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';

class UploadLogoScreen extends StatefulWidget {
  const UploadLogoScreen({Key? key}) : super(key: key);

  @override
  State<UploadLogoScreen> createState() => _UploadLogoScreenState();
}

class _UploadLogoScreenState extends State<UploadLogoScreen> {
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveToLocalAndDatabase() async {
    if (_imageFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(_imageFile!.path);
    final savedImage = await _imageFile!.copy('${appDir.path}/$fileName');

    final db = await DatabaseService.instance.database;

    await db.update(
      'user',
      {'company_logo_url': savedImage.path},
      where: 'id = ?', whereArgs: [1], // adjust for your app's logic
    );

    print('Logo saved locally at: ${savedImage.path}');
    Navigator.pushNamed(context, "/companyinfo");
  }

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
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _imageFile == null
                      ? const Icon(Icons.upload_file,
                          size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 30),
              Buttoncomponent(
                  text: "Continue",
                  onPressed: _saveToLocalAndDatabase,
                  color: primaryColor,
                  textStyle: buttonTextStyle),
              const SizedBox(height: 5),
              SkipButton(onTap: () {
                Navigator.pushNamed(context, "/companyinfo");
              }),
            ],
          ),
        ),
      ),
    );
  }
}
