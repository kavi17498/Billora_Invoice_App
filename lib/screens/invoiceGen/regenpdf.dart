import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart'; // Import for sharing
import 'dart:io'; // Needed to check if file exists

class Regenpdf extends StatelessWidget {
  final String filePath;

  const Regenpdf({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice Preview"),
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
            icon: const Icon(Icons.share, color: Colors.black),
            label: const Text(
              'Share',
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}
