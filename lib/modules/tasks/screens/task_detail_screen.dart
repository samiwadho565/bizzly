import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:bizly/models/tasks_model.dart';
import 'package:bizly/modules/tasks/controllers/task_detail_controller.dart';
import 'package:bizly/utils/app_colors.dart';
import 'package:bizly/utils/app_utils.dart';
import 'package:bizly/utils/date_formats.dart';

class TaskDetailScreen extends GetView<TaskDetailController> {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Obx(() {
        final TaskModel? task = controller.task.value;
        if (task == null) {
          return const Center(child: Text('Task not found'));
        }
        return _Body(task: task, controller: controller);
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
class _Body extends StatelessWidget {
  const _Body({required this.task, required this.controller});
  final TaskModel task;
  final TaskDetailController controller;

  String get _date {
    final DateTime? p = task.dueDateParsed;
    if (p != null) return DateFormats.dMonY(p);
    final String r = task.dueDate.trim();
    return r.isEmpty ? '—' : r;
  }

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Column(
        children: [
          // ── Gradient App Bar ─────────────────────────────────
          _AppBar(topPad: topPad, task: task, controller: controller),

          // ── Scrollable Body ──────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title Card ────────────────────────────────
                  _TitleCard(task: task),
                  const SizedBox(height: 16),

                  // ── Detail Info Card ──────────────────────────
                  _InfoCard(task: task, date: _date, controller: controller),
                  const SizedBox(height: 16),

                  // ── Attachments ───────────────────────────────
                  if (task.attachments.isNotEmpty) ...[
                    _AttachmentsCard(task: task, controller: controller),
                    const SizedBox(height: 16),
                  ],

                  // ── Action Buttons ────────────────────────────
                  _ActionButtons(controller: controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Gradient App Bar
// ─────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.topPad,
    required this.task,
    required this.controller,
  });
  final double topPad;
  final TaskModel task;
  final TaskDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, topPad + 8, 12, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A1628), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
            splashRadius: 22,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Detail',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                if ((task.businessName?.trim().isNotEmpty) == true)
                  Text(
                    task.businessName!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.50),
                      fontSize: 11.5,
                    ),
                  ),
              ],
            ),
          ),
          // Edit icon
          _AppBarBtn(
            icon: Icons.edit_rounded,
            onTap: controller.editTask,
          ),
          const SizedBox(width: 8),
          // Delete icon
          _AppBarBtn(
            icon: Icons.delete_outline_rounded,
            iconColor: const Color(0xFFFF6B6B),
            onTap: controller.deleteTask,
          ),
        ],
      ),
    );
  }
}

class _AppBarBtn extends StatelessWidget {
  const _AppBarBtn({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Title Card — title + description + badges
// ─────────────────────────────────────────────────────────────────
class _TitleCard extends StatelessWidget {
  const _TitleCard({required this.task});
  final TaskModel task;

  _StatusStyle get _ss {
    switch (task.displayStatus.toLowerCase()) {
      case 'done':
        return const _StatusStyle(
          bg: Color(0xFFECFDF5), fg: Color(0xFF059669), icon: Icons.check_circle_rounded);
      case 'in progress':
        return const _StatusStyle(
          bg: Color(0xFFEFF6FF), fg: Color(0xFF3B82F6), icon: Icons.pending_rounded);
      default:
        return const _StatusStyle(
          bg: Color(0xFFF5F3FF), fg: Color(0xFF7C3AED), icon: Icons.circle_outlined);
    }
  }

  Color get _priorityDot {
    switch (task.priorityLevel) {
      case 1: return const Color(0xFFEF5350);
      case 2: return const Color(0xFFFFB300);
      default: return const Color(0xFF26A69A);
    }
  }

  String get _priorityLabel {
    switch (task.priorityLevel) {
      case 1: return 'High Priority';
      case 2: return 'Medium Priority';
      default: return 'Low Priority';
    }
  }

  @override
  Widget build(BuildContext context) {
    final _StatusStyle ss = _ss;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges row
          Row(
            children: [
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: ss.bg,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(ss.icon, size: 12, color: ss.fg),
                    const SizedBox(width: 5),
                    Text(
                      task.displayStatus,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ss.fg),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Priority
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _priorityDot.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: _priorityDot),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _priorityLabel,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _priorityDot),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Title
          Text(
            task.taskTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
              letterSpacing: -0.3,
            ),
          ),

          // Description
          if (task.description.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              task.description,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Info Card
// ─────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.task,
    required this.date,
    required this.controller,
  });
  final TaskModel task;
  final String date;
  final TaskDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF3B82F6),
            label: 'Due Date',
            value: date,
          ),
          _divider(),
          _InfoRow(
            icon: Icons.person_rounded,
            iconBg: const Color(0xFFF5F3FF),
            iconColor: const Color(0xFF7C3AED),
            label: 'Assigned To',
            valueWidget: GestureDetector(
              onTap: controller.openAssignedEmployeeDetail,
              child: Text(
                task.assignedEmployeeName?.isNotEmpty == true
                    ? task.assignedEmployeeName!
                    : '—',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: task.assignTo != null
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  decoration: task.assignTo != null
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ),
          ),
          if ((task.businessName?.trim().isNotEmpty) == true) ...[
            _divider(),
            _InfoRow(
              icon: Icons.business_rounded,
              iconBg: const Color(0xFFFFFBEB),
              iconColor: const Color(0xFFD97706),
              label: 'Business',
              value: task.businessName!,
            ),
          ],
          _divider(),
          _InfoRow(
            icon: Icons.access_time_rounded,
            iconBg: const Color(0xFFF0FDF4),
            iconColor: const Color(0xFF16A34A),
            label: 'Created',
            value: _formatCreated(task.createdAt),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.only(left: 72),
        child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
      );

  String _formatCreated(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '—';
    final DateTime? dt = DateTime.tryParse(raw.trim());
    if (dt == null) return raw.trim();
    return DateFormats.dMonY(dt);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.value,
    this.valueWidget,
    this.isLast = false,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, isLast ? 14 : 14),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                valueWidget ??
                    Text(
                      value ?? '—',
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Attachments Card
// ─────────────────────────────────────────────────────────────────
class _AttachmentsCard extends StatelessWidget {
  const _AttachmentsCard({required this.task, required this.controller});
  final TaskModel task;
  final TaskDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.attach_file_rounded,
                    size: 18, color: Color(0xFFEA580C)),
              ),
              const SizedBox(width: 12),
              const Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${task.attachments.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: task.attachments.map((a) {
              return GestureDetector(
                onTap: () => _openPreview(context, a.fileUrl),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: a.fileUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 90,
                          height: 90,
                          color: const Color(0xFFF1F5F9),
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 90,
                          height: 90,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.broken_image_rounded,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.deleteAttachment(a),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.60),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _openPreview(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
          ),
          actions: [
            IconButton(
              onPressed: () => _download(url),
              icon: const Icon(Icons.download_rounded, color: Colors.white),
            ),
          ],
        ),
        body: Center(
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              errorWidget: (_, __, ___) => const Icon(
                Icons.broken_image_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _download(String url) async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String ext = _ext(url);
      final String path =
          '${dir.path}/task_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await Dio().download(url, path);
      AppUtils.showAppSnackbar('Downloaded', 'Saved to $path',
          snackPosition: SnackPosition.BOTTOM, type: AppSnackType.success);
    } catch (_) {
      AppUtils.showAppSnackbar('Error', 'Unable to download image',
          snackPosition: SnackPosition.BOTTOM, type: AppSnackType.error);
    }
  }

  String _ext(String url) {
    final String p = Uri.tryParse(url)?.path ?? '';
    final String last = p.split('.').last.toLowerCase();
    return {'png', 'jpg', 'jpeg', 'webp'}.contains(last) ? last : 'jpg';
  }
}

// ─────────────────────────────────────────────────────────────────
// Action Buttons
// ─────────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.controller});
  final TaskDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Edit — filled primary
        Expanded(
          child: GestureDetector(
            onTap: controller.editTask,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Edit Task',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Delete — outlined danger
        Expanded(
          child: GestureDetector(
            onTap: controller.deleteTask,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFEF4444).withOpacity(0.40), width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444), size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────
class _StatusStyle {
  final Color bg;
  final Color fg;
  final IconData icon;
  const _StatusStyle({required this.bg, required this.fg, required this.icon});
}
