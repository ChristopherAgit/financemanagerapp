import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  AppDecorations._();

  static BoxDecoration card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.borderColor),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration alertCard = BoxDecoration(
    color: const Color(0xFFFFFBEB),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AppColors.warning.withOpacity(0.35)),
  );

  static BoxDecoration rowItem = BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(10),
  );

  static InputDecoration inputField({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          color: AppColors.lightText, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.mutedText, size: 18),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
        const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    foregroundColor: Colors.white,
    elevation: 0,
    disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  static BoxDecoration iconContainer = BoxDecoration(
    color: AppColors.accent.withOpacity(0.08),
    borderRadius: BorderRadius.circular(8),
  );
}