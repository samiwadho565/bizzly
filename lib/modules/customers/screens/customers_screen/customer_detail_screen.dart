import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bizly/modules/customers/models/customer_model.dart';
import 'package:bizly/routes/routes.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_dialouge.dart';
import 'package:bizly/modules/customers/controllers/customers_controller.dart';
import 'package:bizly/assets/images.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Rx<CustomerModel> customerRx;

  CustomerDetailScreen({super.key, required CustomerModel customer})
      : customerRx = customer.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final CustomerModel customer = customerRx.value;
      final double topPad = MediaQuery.of(context).padding.top;
      final double bottomPad = MediaQuery.of(context).padding.bottom;

      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            // ── Fixed Gradient Hero ────────────────────────────
            _buildHero(context, customer, topPad),

            // ── Scrollable Info ────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Contact info
                    _sectionTitle('Contact'),
                    const SizedBox(height: 10),
                    _infoGroup(<_InfoRow>[
                      _InfoRow(Icons.phone_rounded, 'Phone',
                          customer.phoneNumber, const Color(0xFFE53935)),
                      if ((customer.email ?? '').isNotEmpty)
                        _InfoRow(Icons.email_rounded, 'Email',
                            customer.email!, const Color(0xFF1565C0)),
                      if ((customer.secondaryPhoneNumber ?? '').isNotEmpty)
                        _InfoRow(Icons.phone_android_rounded, 'Secondary',
                            customer.secondaryPhoneNumber!,
                            const Color(0xFF00897B)),
                    ]),

                    const SizedBox(height: 20),

                    // Address
                    _sectionTitle('Address'),
                    const SizedBox(height: 10),
                    _infoGroup(<_InfoRow>[
                      _InfoRow(Icons.location_on_rounded, 'Address',
                          customer.address, const Color(0xFF00897B)),
                    ]),

                    // Optional fields
                    if (_hasOptional(customer)) ...<Widget>[
                      const SizedBox(height: 20),
                      _sectionTitle('Additional Details'),
                      const SizedBox(height: 10),
                      _infoGroup(<_InfoRow>[
                        if ((customer.companyName ?? '').isNotEmpty)
                          _InfoRow(Icons.business_rounded, 'Company',
                              customer.companyName!, const Color(0xFF1565C0)),
                        if ((customer.taxNtn ?? '').isNotEmpty)
                          _InfoRow(Icons.numbers_rounded, 'Tax / NTN',
                              customer.taxNtn!, const Color(0xFFF57C00)),
                        if ((customer.website ?? '').isNotEmpty)
                          _InfoRow(Icons.language_rounded, 'Website',
                              customer.website!, const Color(0xFF00897B)),
                        if ((customer.socialLink ?? '').isNotEmpty)
                          _InfoRow(Icons.share_rounded, 'Social Link',
                              customer.socialLink!, const Color(0xFF8E24AA)),
                        if ((customer.notes ?? '').isNotEmpty)
                          _InfoRow(Icons.notes_rounded, 'Notes',
                              customer.notes!, const Color(0xFF546E7A)),
                      ]),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ── Fixed Bottom Actions ───────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(color: Colors.grey.shade100, width: 1)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  // Edit button (outline)
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFF1565C0), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          foregroundColor: const Color(0xFF1565C0),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text(
                          'Edit',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        onPressed: () async {
                          final dynamic updated = await Get.toNamed(
                            Routes.createCustomerScreen,
                            arguments: customer,
                          );
                          if (updated is CustomerModel) {
                            customerRx.value = updated;
                          }
                        },
                      ),
                    ),
                  ),
                  // const SizedBox(width: 12),
                  // // Create Invoice (gradient)
                  // Expanded(
                  //   flex: 2,
                  //   child: SizedBox(
                  //     height: 50,
                  //     child: DecoratedBox(
                  //       decoration: BoxDecoration(
                  //         gradient: const LinearGradient(
                  //           colors: <Color>[
                  //             Color(0xFF1565C0),
                  //             Color(0xFF0A2472),
                  //           ],
                  //           begin: Alignment.topLeft,
                  //           end: Alignment.bottomRight,
                  //         ),
                  //         borderRadius: BorderRadius.circular(14),
                  //         boxShadow: <BoxShadow>[
                  //           BoxShadow(
                  //             color:
                  //                 const Color(0xFF1565C0).withOpacity(0.30),
                  //             blurRadius: 10,
                  //             offset: const Offset(0, 4),
                  //           ),
                  //         ],
                  //       ),
                  //       child: ElevatedButton.icon(
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: Colors.transparent,
                  //           shadowColor: Colors.transparent,
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(14)),
                  //         ),
                  //         icon: const Icon(Icons.receipt_long_rounded,
                  //             color: Colors.white, size: 18),
                  //         label: const Text(
                  //           'Create Invoice',
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontWeight: FontWeight.w700,
                  //             fontSize: 15,
                  //           ),
                  //         ),
                  //         onPressed: () {
                  //           Get.toNamed(
                  //             Routes.createInvoiceScreen,
                  //             arguments: <String, dynamic>{
                  //               'customerId': customer.id,
                  //               'customerName': customer.customerName,
                  //               'lockCustomer': true,
                  //             },
                  //           );
                  //         },
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // Hero
  // ─────────────────────────────────────────────────────────────────

  Widget _buildHero(
      BuildContext context, CustomerModel customer, double topPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF1565C0), Color(0xFF0A2472)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: <Widget>[
          // Decorative circles
          Positioned(
            top: -30,
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
            bottom: -20,
            left: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          Column(
            children: <Widget>[
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        size: 18,
                      ),
                    ),
                  ),
                  // Delete menu
                  PopupMenuButton<String>(
                    icon: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.more_vert_rounded,
                          color: Colors.white, size: 20),
                    ),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    onSelected: (_) {
                      AppDialogs.showActionDialog(
                        iconPath: AppImages.dialogTrash,
                        title: 'Delete Customer',
                        message:
                            'Are you sure you want to delete ${customer.customerName}?',
                        actions: <AppDialogAction>[
                          AppDialogAction(label: 'Cancel'),
                          AppDialogAction(
                            label: 'Delete',
                            textColor: Colors.red,
                            onPressed: () {
                              if (!Get.isRegistered<CustomersController>()) {
                                return;
                              }
                              Get.find<CustomersController>()
                                  .deleteCustomer(customer);
                            },
                          ),
                        ],
                      );
                    },
                    itemBuilder: (_) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.delete_outline_rounded,
                                color: Colors.red, size: 18),
                            SizedBox(width: 10),
                            Text('Delete Customer',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Avatar + info
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                      border:
                          Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      child: ClipOval(
                        child: (customer.profileImage != null &&
                                customer.profileImage!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: customer.profileImage!,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const Image(
                                  image: AssetImage(
                                      AppImages.profilePlaceholder),
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (_, __, ___) =>
                                    _initialsWidget(customer.customerName),
                              )
                            : _initialsWidget(customer.customerName),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          customer.customerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            shadows: <Shadow>[
                              Shadow(
                                  color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                        ),
                        if ((customer.companyName ?? '').isNotEmpty) ...<Widget>[
                          const SizedBox(height: 3),
                          Row(
                            children: <Widget>[
                              Icon(Icons.business_rounded,
                                  size: 12,
                                  color: Colors.white.withOpacity(0.7)),
                              const SizedBox(width: 4),
                              Text(
                                customer.companyName!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 3),
                        Row(
                          children: <Widget>[
                            Icon(Icons.phone_rounded,
                                size: 12,
                                color: Colors.white.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Text(
                              customer.phoneNumber,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12,
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

  // ─────────────────────────────────────────────────────────────────
  // Info group
  // ─────────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _infoGroup(List<_InfoRow> rows) {
    final List<_InfoRow> visible = rows;
    if (visible.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List<Widget>.generate(visible.length, (i) {
          final _InfoRow row = visible[i];
          final bool isLast = i == visible.length - 1;
          return Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: row.color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(row.icon, size: 15, color: row.color),
                    ),
                    const SizedBox(width: 12),
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
                            ),
                          ),
                          const SizedBox(height: 2),
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
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 52,
                  color: Colors.grey.shade100,
                ),
            ],
          );
        }),
      ),
    );
  }

  bool _hasOptional(CustomerModel c) =>
      (c.companyName ?? '').isNotEmpty ||
      (c.taxNtn ?? '').isNotEmpty ||
      (c.website ?? '').isNotEmpty ||
      (c.socialLink ?? '').isNotEmpty ||
      (c.notes ?? '').isNotEmpty;

  // ─────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────

  Widget _initialsWidget(String name) {
    final String letter =
        name.trim().isEmpty ? 'C' : name.trim()[0].toUpperCase();
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      color: Colors.white.withOpacity(0.15),
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow(this.icon, this.label, this.value, this.color);
  final IconData icon;
  final String label;
  final String value;
  final Color color;
}
