import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/vendors/models/vendor_model.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/modules/vendors/controllers/vendors_controller.dart';
import 'package:bizly/assets/images.dart';

class VendorDetailScreen extends StatelessWidget {
  final Rx<VendorModel> vendorRx;

  VendorDetailScreen({super.key, required VendorModel vendor})
      : vendorRx = vendor.obs;

  static const LinearGradient _gradient = LinearGradient(
    colors: <Color>[Color(0xFF1565C0), Color(0xFF0A2472)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.of(context).padding.top;
    final double bottomPad = MediaQuery.of(context).padding.bottom;

    return Obx(() {
      final VendorModel vendor = vendorRx.value;
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: <Widget>[
            // ── Fixed Gradient Hero ──────────────────────────────
            _buildHero(vendor, topPad),

            // ── Scrollable Content ───────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Contact Info
                      _infoGroup(<_InfoRow>[
                        _InfoRow(
                          icon: Icons.phone_rounded,
                          label: 'Phone Number',
                          value: vendor.phoneNumber,
                          color: Colors.green.shade700,
                        ),
                        if ((vendor.email ?? '').isNotEmpty)
                          _InfoRow(
                            icon: Icons.email_rounded,
                            label: 'Email',
                            value: vendor.email!,
                            color: Colors.orange.shade700,
                          ),
                      ]),

                      const SizedBox(height: 12),

                      // Address
                      if ((vendor.address ?? '').isNotEmpty)
                        _infoGroup(<_InfoRow>[
                          _InfoRow(
                            icon: Icons.location_on_rounded,
                            label: 'Address',
                            value: vendor.address!,
                            color: Colors.red.shade600,
                          ),
                        ]),

                      // Business Details
                      if ((vendor.companyName ?? '').isNotEmpty ||
                          (vendor.taxNumber ?? '').isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        _infoGroup(<_InfoRow>[
                          if ((vendor.companyName ?? '').isNotEmpty)
                            _InfoRow(
                              icon: Icons.business_rounded,
                              label: 'Company Name',
                              value: vendor.companyName!,
                              color: Colors.purple.shade700,
                            ),
                          if ((vendor.taxNumber ?? '').isNotEmpty)
                            _InfoRow(
                              icon: Icons.confirmation_number_rounded,
                              label: 'Tax / NTN',
                              value: vendor.taxNumber!,
                              color: Colors.teal.shade700,
                            ),
                        ]),
                      ],

                      // Notes
                      if ((vendor.notes ?? '').isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        _infoGroup(<_InfoRow>[
                          _InfoRow(
                            icon: Icons.notes_rounded,
                            label: 'Notes',
                            value: vendor.notes!,
                            color: Colors.blueGrey.shade600,
                          ),
                        ]),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // ── Fixed Bottom Action Bar ──────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  // Edit (outline)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final dynamic updated = await Get.toNamed(
                          Routes.createVendorScreen,
                          arguments: vendorRx.value,
                        );
                        if (updated is VendorModel) {
                          vendorRx.value = updated;
                        }
                      },
                      icon: const Icon(Icons.edit_rounded, size: 17),
                      label: const Text('Edit Vendor'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        foregroundColor: const Color(0xFF1565C0),
                        side: const BorderSide(
                            color: Color(0xFF1565C0), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add Bill (gradient)
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: _gradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color:
                                const Color(0xFF1565C0).withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.toNamed(
                            Routes.addExpenseScreen,
                            arguments: <String, dynamic>{
                              'vendorId': vendorRx.value.id,
                              'vendorName': vendorRx.value.vendorName,
                              'lockVendor': true,
                            },
                          );
                        },
                        icon: const Icon(Icons.receipt_long_rounded,
                            size: 17, color: Colors.white),
                        label: const Text(
                          'Add Bill',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHero(VendorModel vendor, double topPad) {
    final String letter = vendor.vendorName.trim().isEmpty
        ? 'V'
        : vendor.vendorName.trim()[0].toUpperCase();

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 24),
      decoration: const BoxDecoration(gradient: _gradient),
      child: Stack(
        children: <Widget>[
          // Decorative circles
          Positioned(
            top: -20,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            left: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Back + Delete row
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Delete menu
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () async {
                        AppDialogs.showActionDialog(
                          iconPath: AppImages.dialogTrash,
                          title: 'Delete Vendor!',
                          message:
                              'Are you sure you want to delete ${vendorRx.value.vendorName}?',
                          actions: <AppDialogAction>[
                            AppDialogAction(label: 'Cancel'),
                            AppDialogAction(
                              label: 'Delete Vendor',
                              textColor: Colors.red,
                              onPressed: () {
                                Get.find<VendorsController>()
                                    .deleteVendor(vendorRx.value);
                              },
                            ),
                          ],
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white.withOpacity(0.9),
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Avatar + info
              Row(
                children: <Widget>[
                  // Gradient ring initials
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                    ),
                    child: Container(
                      width: 70,
                      height: 70,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        letter,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          vendor.vendorName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        if ((vendor.companyName ?? '').isNotEmpty) ...<Widget>[
                          const SizedBox(height: 4),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.business_rounded,
                                color: Colors.white.withOpacity(0.7),
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  vendor.companyName!,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.80),
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.phone_rounded,
                              color: Colors.white.withOpacity(0.70),
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              vendor.phoneNumber,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.80),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoGroup(List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List<Widget>.generate(rows.length, (i) {
          final _InfoRow row = rows[i];
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: row.color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          Icon(row.icon, color: row.color, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            row.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            row.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < rows.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade100,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}
