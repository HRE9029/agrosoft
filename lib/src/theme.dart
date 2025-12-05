import 'package:flutter/material.dart';

class AppColors {
  static const headerFooter = Color(0xFF33533F);
  static const fieldFill    = Color(0xFFD0B500);
  static const background   = Color(0xFFFBF2E7);
  static const buttons      = Color(0xFF27251F);
}

ThemeData buildAgroTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color.fromRGBO(251, 242, 231, 1),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.headerFooter,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      titleMedium: TextStyle(fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color.fromARGB(255, 230, 224, 216),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(color: Colors.black87),
    ),
  );
}
