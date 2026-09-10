import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // الألوان الرئيسية
  static const Color primary = Color(0xFF2E7D32); // أخضر داكن
  static const Color primaryLight = Color(0xFF4CAF50); // أخضر فاتح
  static const Color primaryDark = Color(0xFF1B5E20); // أخضر غامق

  // الألوان الثانوية
  static const Color secondary = Color(0xFFFF9800); // برتقالي
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFF57C00);

  // ألوان الخلفية
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFAFAFA);

  // ألوان النصوص
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  // ألوان الحالة
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // ألوان خاصة
  static const Color cashGreen = Color(0xFF66BB6A);
  static const Color walletBlue = Color(0xFF42A5F5);
  static const Color dangerRed = Color(0xFFEF5350);

  // ألوان الرسم البياني
  static const List<Color> chartColors = [
    Color(0xFF2E7D32),
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFFF44336),
    Color(0xFF9C27B0),
    Color(0xFF009688),
    Color(0xFFFF5722),
    Color(0xFF3F51B5),
  ];

  // التدرجات
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryLight, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}