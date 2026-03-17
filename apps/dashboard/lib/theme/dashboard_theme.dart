import 'package:flutter/material.dart';

class DashboardColors {
  static const Color primary = Color(0xFF030213);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F8FA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0x1A000000);
  static const Color accent = Color(0xFFE9EBEF);
  static const Color muted = Color(0xFFECECF0);
  static const Color mutedForeground = Color(0xFF717182);
  static const Color destructive = Color(0xFFEF4444);
  static const Color inputBg = Color(0xFFF3F3F5);
  static const Color green = Color(0xFF22C55E);
  static const Color greenLight = Color(0xFFDCFCE7);
  static const Color greenText = Color(0xFF15803D);
  static const Color yellowLight = Color(0xFFFEF9C3);
  static const Color yellowText = Color(0xFFA16207);
  static const Color blueLight = Color(0xFFDBEAFE);
  static const Color blueText = Color(0xFF1D4ED8);
}

class DashboardTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: 'sans-serif',
        splashFactory: NoSplash.splashFactory,
        colorScheme: const ColorScheme.light(
          primary: DashboardColors.primary,
          onPrimary: DashboardColors.primaryForeground,
          surface: DashboardColors.card,
          onSurface: DashboardColors.primary,
          error: DashboardColors.destructive,
        ),
        scaffoldBackgroundColor: DashboardColors.background,
        cardTheme: CardThemeData(
          color: DashboardColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: DashboardColors.border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: DashboardColors.inputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: DashboardColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: DashboardColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: DashboardColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isDense: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: DashboardColors.primary,
            foregroundColor: DashboardColors.primaryForeground,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: DashboardColors.primary,
            side: const BorderSide(color: DashboardColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
}
