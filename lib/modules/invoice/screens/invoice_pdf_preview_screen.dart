import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'package:bizly/components/common/custom_app_bar_2.dart';
import 'package:bizly/utils/app_colors.dart';

class InvoicePdfPreviewScreen extends StatelessWidget {
  const InvoicePdfPreviewScreen({
    super.key,
    required this.bytes,
    required this.filePath,
  });

  final Uint8List bytes;
  final String filePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar2(
        title: 'Invoice PDF Preview',
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
            child: PdfPreview(
              build: (format) async => bytes,
            ),
          ),
        ],
      ),
    );
  }
}
