import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoiceapp/services/database_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:invoiceapp/components/ScreenHeader.dart';
import 'package:invoiceapp/components/BottomActionBar.dart';
import 'package:invoiceapp/constrains/Colors.dart';
import 'package:invoiceapp/constrains/TextStyles.dart';
import 'package:invoiceapp/constrains/Dimensions.dart';

class UploadLogoScreen extends StatefulWidget {
  const UploadLogoScreen({super.key});

  @override
  State<UploadLogoScreen> createState() => _UploadLogoScreenState();
}

class _UploadLogoScreenState extends State<UploadLogoScreen> {
  File? _imageFile;
  bool _isLoading = false;

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
      _showError("Please select an image");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
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
    } catch (e) {
      _showError("Failed to save logo. Please try again.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    const ScreenHeader(
                      title: 'Upload Your\nBusiness Logo',
                      subtitle: "Add your logo to make professional invoices",
                      centerTitle: true,
                    ),
                    SizedBox(height: AppSpacing.xl * 2),

                    // Logo upload section
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              color: _imageFile != null
                                  ? AppColors.surface
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _imageFile != null
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              image: (_imageFile != null &&
                                      _imageFile!.existsSync())
                                  ? DecorationImage(
                                      image: FileImage(_imageFile!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _imageFile == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cloud_upload_rounded,
                                        size: 48,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(height: AppSpacing.sm),
                                      Text(
                                        "Tap to upload",
                                        style:
                                            AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                        if (_imageFile != null)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _imageFile = null;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadow.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom action buttons
              BottomActionBar(
                primaryButtonText: "Continue",
                onPrimaryPressed: _saveToLocalAndDatabase,
                primaryButtonLoading: _isLoading,
                primaryButtonEnabled: !_isLoading,
                onSkipPressed: () =>
                    Navigator.pushNamed(context, "/companyinfo"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
