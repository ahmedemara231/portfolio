import 'package:flutter/material.dart';

Color parseColor(String? hex, [Color fallback = Colors.grey]) {
  if (hex == null || hex.isEmpty) return fallback;
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length == 8) {
    final value = int.tryParse(hex, radix: 16);
    if (value != null) return Color(value);
  }
  return fallback;
}
