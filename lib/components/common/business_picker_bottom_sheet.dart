import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:bizly/modules/business/models/business_model.dart';
import 'package:bizly/utils/app_colors.dart';

Future<BusinessModel?> showBusinessPickerBottomSheet(
  BuildContext context, {
  required List<BusinessModel> businesses,
  int? selectedBusinessId,
  String title = 'Select Business',
}) {
  final double maxHeight = MediaQuery.of(context).size.height * 0.7;

  return showModalBottomSheet<BusinessModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      splashRadius: 18,
                      color: Colors.black54,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListView.separated(
                    itemCount: businesses.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final BusinessModel business = businesses[index];
                      final bool isSelected = selectedBusinessId == business.id;
                      return ListTile(
                        onTap: () => Navigator.of(context).pop(business),
                        contentPadding: EdgeInsets.zero,
                        leading: _businessAvatar(business.businessImageUrl),
                        title: Text(
                          business.businessName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              )
                            : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _businessAvatar(String? imageUrl) {
  final String normalized = imageUrl?.trim() ?? '';
  if (normalized.isEmpty) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColors.greyCard,
      child: const Icon(Icons.business, size: 14, color: Colors.black54),
    );
  }
  return ClipOval(
    child: CachedNetworkImage(
      imageUrl: normalized,
      width: 28,
      height: 28,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => CircleAvatar(
        radius: 14,
        backgroundColor: AppColors.greyCard,
        child: const Icon(Icons.business, size: 14, color: Colors.black54),
      ),
    ),
  );
}
