import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bizly/components/common/gradient_screen_header.dart';
import 'package:bizly/modules/chart_of_accounts/controllers/coa_controller.dart';
import 'package:bizly/modules/chart_of_accounts/models/coa_model.dart';
import 'package:bizly/modules/chart_of_accounts/screens/create_coa_screen.dart';
import 'package:bizly/utils/app_colors.dart';

class CoaDetailScreen extends StatelessWidget {
  const CoaDetailScreen({super.key, required this.account});
  final CoaModel account;

  @override
  Widget build(BuildContext context) {
    final CoaController c = Get.find<CoaController>();
    if (c.currentDetailAccount.value?.id != account.id) {
      c.currentDetailAccount.value = account;
    }

    return Obx(() {
      final CoaModel current = c.currentDetailAccount.value ?? account;
      final bool loading = c.isTogglingActive.value;
      final bool canEdit = current.isEditable;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            GradientScreenHeader(
              title: 'Account Detail',
              actions: canEdit
                  ? [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white),
                        onPressed: () async {
                          c.prepareEdit(current);
                          final bool? updated =
                              await Get.to(() => const CreateCoaScreen());
                          if (updated == true) Get.back();
                        },
                      ),
                    ]
                  : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero Account Card ────────────────────────
                    _AccountHeroCard(account: current),
                    const SizedBox(height: 16),

                    // ── Detail Info Card ─────────────────────────
                    _DetailInfoCard(account: current),
                    const SizedBox(height: 16),

                    // ── System account notice ────────────────────
                    if (!canEdit) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFF0D47A1).withOpacity(0.12)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D47A1).withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF0D1B4B),
                                    Color(0xFF1565C0),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.lock_rounded,
                                  size: 16, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'System Account',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0D1B4B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'This account is managed by the system and cannot be edited.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // ── Toggle Active Button ─────────────────────
                    if (canEdit)
                      Builder(builder: (_) {
                        final bool active = current.isActive;
                        return GestureDetector(
                          onTap: loading ? null : () => c.toggleActive(current),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 54,
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFFC62828).withOpacity(0.07)
                                  : const Color(0xFF2E7D32).withOpacity(0.07),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: active
                                    ? const Color(0xFFC62828).withOpacity(0.35)
                                    : const Color(0xFF2E7D32).withOpacity(0.35),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (loading)
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: active
                                          ? const Color(0xFFC62828)
                                          : const Color(0xFF2E7D32),
                                    ),
                                  )
                                else
                                  Icon(
                                    active
                                        ? Icons.block_rounded
                                        : Icons.check_circle_rounded,
                                    size: 18,
                                    color: active
                                        ? const Color(0xFFC62828)
                                        : const Color(0xFF2E7D32),
                                  ),
                                const SizedBox(width: 10),
                                Text(
                                  loading
                                      ? (active
                                          ? 'Deactivating...'
                                          : 'Activating...')
                                      : (active
                                          ? 'Deactivate Account'
                                          : 'Activate Account'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: active
                                        ? const Color(0xFFC62828)
                                        : const Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Account Hero Card ────────────────────────────────────────────
class _AccountHeroCard extends StatelessWidget {
  const _AccountHeroCard({required this.account});
  final CoaModel account;

  static _NatureTheme _theme(String nature) {
    switch (nature.toLowerCase()) {
      case 'asset':
        return const _NatureTheme(
          start: Color(0xFF0D47A1),
          end: Color(0xFF1976D2),
          icon: Icons.account_balance_rounded,
        );
      case 'liability':
        return const _NatureTheme(
          start: Color(0xFFB71C1C),
          end: Color(0xFFE53935),
          icon: Icons.trending_down_rounded,
        );
      case 'equity':
        return const _NatureTheme(
          start: Color(0xFF4A148C),
          end: Color(0xFF8E24AA),
          icon: Icons.pie_chart_rounded,
        );
      case 'income':
        return const _NatureTheme(
          start: Color(0xFF1B5E20),
          end: Color(0xFF43A047),
          icon: Icons.trending_up_rounded,
        );
      case 'expense':
        return const _NatureTheme(
          start: Color(0xFFE65100),
          end: Color(0xFFF57C00),
          icon: Icons.receipt_long_rounded,
        );
      default:
        return const _NatureTheme(
          start: Color(0xFF0D1B4B),
          end: Color(0xFF1565C0),
          icon: Icons.account_tree_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _NatureTheme t = _theme(account.nature);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [t.start, t.end],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: t.end.withOpacity(0.38),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nature badge + Active indicator
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(t.icon, size: 13, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            account.nature.capitalize!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Active/Inactive pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: account.isActive
                            ? Colors.green.withOpacity(0.22)
                            : Colors.grey.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: account.isActive
                              ? Colors.greenAccent.withOpacity(0.40)
                              : Colors.grey.withOpacity(0.40),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: account.isActive
                                  ? const Color(0xFF69F0AE)
                                  : Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            account.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: account.isActive
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Account name
                Text(
                  account.accountName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                // Account code
                Text(
                  account.accountCode,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!account.isGlobal) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 12, color: Colors.white.withOpacity(0.65)),
                      const SizedBox(width: 5),
                      Text(
                        'Custom Account',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.65)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail Info Card ─────────────────────────────────────────────
class _DetailInfoCard extends StatelessWidget {
  const _DetailInfoCard({required this.account});
  final CoaModel account;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Account Info',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow('Level', 'Level ${account.level}'),
          if (account.parentName != null)
            _infoRow('Parent', account.parentName!),
          _infoRow('Nature', account.nature.capitalize!),
          _infoRow('Type', account.isGlobal ? 'System' : 'Custom'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NatureTheme {
  final Color start;
  final Color end;
  final IconData icon;
  const _NatureTheme({
    required this.start,
    required this.end,
    required this.icon,
  });
}
