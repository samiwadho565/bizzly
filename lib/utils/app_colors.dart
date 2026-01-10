import 'package:flutter/material.dart';

class AppColors {
  /// Primary & Background
  static const Color primary = Color(0xFF7C41A9);
  static const Color background = Color(0xFFF7FAFC);
  static const Color lightGrey = Color(0xFFEDEDEF);
  static const Color transparentWhite = Colors.white38;

  /// ===============================
  /// STATUS COLORS
  /// ===============================

  // Payment / Invoice Status
  static const Color statusPaid = Color(0xFF22C55E);       // Green
  static const Color statusPending = Color(0xFFF59E0B);    // Orange
  static const Color statusOverdue = Color(0xFFEF4444);    // Red
  static const Color statusCancelled = Color(0xFF9CA3AF); // Grey
  static const Color statusCompleted = Color(0xFF3B82F6); // Blue
  static const Color statusSent = Color(0xFF6366F1);      // Indigo

  /// ===============================
  /// PRIORITY COLORS
  /// ===============================

  static const Color priorityLow = Color(0xFF10B981);    // Soft Green
  static const Color priorityMedium = Color(0xFFF59E0B); // Orange
  static const Color priorityHigh = Color(0xFFEF4444);   // Red

  /// ===============================
  /// ACTIVE / INACTIVE COLORS
  /// ===============================

  static const Color active = Color(0xFF16A34A);     // Dark Green
  static const Color inactive = Color(0xFF9CA3AF);   // Muted Grey
  static const Color disabled = Color(0xFFD1D5DB);   // Light Grey (Optional)

  /// ===============================
  /// TEXT COLORS (Optional)
  /// ===============================

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
}
