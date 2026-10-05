import 'package:core/core.dart';
import 'package:flutter/material.dart';

class DashboardColors {
  static const primary = Design.accent,
      primaryForeground = Colors.white,
      background = Design.paper,
      card = Design.surface,
      border = Design.line,
      accent = Design.tint,
      muted = Design.tint,
      mutedForeground = Design.muted,
      destructive = Design.error,
      inputBg = Design.surface,
      green = Design.accent,
      greenLight = Design.tint,
      greenText = Design.accent,
      yellowLight = Color(0xFFFFF1D3),
      yellowText = Color(0xFF7D571D),
      blueLight = Design.tint,
      blueText = Design.accent;
}

class DashboardTheme {
  static ThemeData get light => Design.theme.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Design.paper,
      foregroundColor: Design.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 72,
      titleTextStyle: TextStyle(
        fontFamily: Design.font,
        color: Design.ink,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Design.muted,
      textColor: Design.ink,
    ),
  );
}
