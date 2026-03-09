import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/utils/app_colors.dart';

class InvoiceImagePreviewScreen extends StatelessWidget {
  const InvoiceImagePreviewScreen({
    super.key,
    required this.bytes,
    required this.filePath,
    this.title = 'Invoice Image Preview',
  });

  final Uint8List bytes;
  final String filePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar2(
        title: title,
        backgroundColor: AppColors.primaryDense,
        textColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            color: AppColors.primaryDense,
            child: Text(
              filePath,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 5,
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
