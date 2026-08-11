import 'package:flutter/material.dart';
import 'package:bizly/utils/app_colors.dart';

class TaskCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String assignTo;
  final String status;
  final int priority; // 1=High, 2=Medium, 3=Low
  final String userImageUrl;

  const TaskCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.priority,
    required this.assignTo,
    required this.status,
    this.userImageUrl = '',
  });

  // ── Priority ───────────────────────────────────────────────────
  String get _priorityLabel {
    switch (priority) {
      case 1: return 'High';
      case 2: return 'Med';
      default: return 'Low';
    }
  }

  Color get _priorityDot {
    switch (priority) {
      case 1: return const Color(0xFFEF5350);
      case 2: return const Color(0xFFFFB300);
      default: return const Color(0xFF26A69A);
    }
  }

  // ── Status ─────────────────────────────────────────────────────
  _StatusStyle get _statusStyle {
    switch (status.toLowerCase()) {
      case 'done':
        return const _StatusStyle(
          bg: Color(0xFFECFDF5),
          fg: Color(0xFF059669),
          icon: Icons.check_circle_rounded,
        );
      case 'in progress':
        return const _StatusStyle(
          bg: Color(0xFFEFF6FF),
          fg: Color(0xFF3B82F6),
          icon: Icons.pending_rounded,
        );
      default:
        return const _StatusStyle(
          bg: Color(0xFFF5F3FF),
          fg: Color(0xFF7C3AED),
          icon: Icons.circle_outlined,
        );
    }
  }

  // Initials avatar
  String get _initials {
    final List<String> parts =
        assignTo.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final _StatusStyle ss = _statusStyle;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Title + Status badge ─────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                // Status badge — icon + text
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: ss.bg,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(ss.icon, size: 11, color: ss.fg),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: ss.fg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Description ─────────────────────────────────────
            if (subtitle.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 14),

            // ── Divider ─────────────────────────────────────────
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

            const SizedBox(height: 12),

            // ── Footer row ──────────────────────────────────────
            Row(
              children: [
                // Assignee avatar circle
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF022B6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    assignTo,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Date
                Icon(Icons.schedule_rounded, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(width: 10),

                // Priority pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _priorityDot.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _priorityDot,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _priorityLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _priorityDot,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusStyle {
  final Color bg;
  final Color fg;
  final IconData icon;
  const _StatusStyle({required this.bg, required this.fg, required this.icon});
}
