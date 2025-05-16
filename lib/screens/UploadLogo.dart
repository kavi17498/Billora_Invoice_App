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
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an image"),
        ),
      );
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(_imageFile!.path);
    final savedImage = await _imageFile!.copy('${appDir.path}/$fileName');

    final db = await DatabaseService.instance.getdatabase();

    await db.update(
      'user',
      {'company_logo_url': savedImage.path},
      where: 'id = ?',
      whereArgs: [1],
    );

    print('Logo saved locally at: ${savedImage.path}');
    Navigator.pushNamed(context, "/companyinfo");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text('Upload Your\nBusiness Logo',
                  textAlign: TextAlign.center, style: primaryTextStyle),
              const SizedBox(height: 30),

              // ✅ Updated section with Stack
              Stack(
                alignment: Alignment.topRight,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                        image: (_imageFile != null && _imageFile!.existsSync())
                            ? DecorationImage(
                                image: FileImage(_imageFile!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _imageFile == null
                          ? const Icon(Icons.upload_file,
                              size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                  if (_imageFile != null)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _imageFile = null;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 30),
              Buttoncomponent(
                text: "Continue",
                onPressed: _saveToLocalAndDatabase,
                color: primaryColor,
                textStyle: buttonTextStyle,
              ),
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
