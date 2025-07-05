import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';

class PdfPreviewPage extends StatelessWidget {
  final String filePath;

  const PdfPreviewPage({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to dashboard with client section selected
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/dashboard",
          (route) => false,
          arguments: 1, // Client section index
        );
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Invoice Preview"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate to dashboard with client section selected
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/dashboard",
                (route) => false,
                arguments: 1, // Client section index
              );
            },
          ),
          actions: [
          TextButton.icon(
            onPressed: () async {
              final file = File(filePath);
              if (await file.exists()) {
                Share.shareXFiles([XFile(filePath)], text: 'Invoice PDF');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF file not found')),
                );
              }
            },
            icon: const Icon(Icons.share, color: Colors.white),
            label: const Text(
              'Share',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: PDFView(
        filePath: filePath,
      ),
    ),
  );
  }
}
