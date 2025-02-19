import 'package:flutter/material.dart';

class AppTheme {
  // الألوان الرئيسية
  static const Color primaryBlue = Color(0xFF1E88E5); // أزرق
  static const Color lightBlue = Color(0xFF90CAF9); // لبني
  static const Color white = Colors.white; // أبيض
  static const Color skyBlue = Color(0xFFBBDEFB); // لبني فاتح

  static final ThemeData lightTheme = ThemeData(
    // الألوان الأساسية
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: white,

    // شريط التطبيق
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // الأزرار
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // حقول الإدخال
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: skyBlue.withOpacity(0.1),
      prefixIconColor: primaryBlue,
      suffixIconColor: primaryBlue,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightBlue),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: primaryBlue),
    ),

    // زر العائم
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: white,
    ),

    // لون المؤشر الدائري
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: white,
    ),
  );

  // نسخة الثيم للوضع المظلم (اختياري)
  static final ThemeData darkTheme = lightTheme;
}
