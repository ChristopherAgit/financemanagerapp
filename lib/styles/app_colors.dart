import 'package:flutter/material.dart';

class AppColors {
  static const Color green = Color(0xFF22C55E);
  static const Color blue = Color(0xFF2563EB);
  static const Color darkText = Color(0xFF1E293B);
  static const Color mutedText = Color(0xFF64748B);
  static const Color lightText = Color(0xFF475569);
  static const Color background = Color(0xFFF1F5F9);
  static const Color cardBg = Colors.white;
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color loginOverlay = Colors.white24;
  static const Color loginCard = Colors.white;
  static const Color inputFill = Color(0xFFF8FAFC);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green, blue],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green, blue],
  );
}