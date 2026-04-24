import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF4F7FB);
  static const Color panel = Colors.white;
  static const Color panelStrong = Color(0xFF0F172A);
  static const Color panelMuted = Color(0xFFF8FAFC);
  static const Color primary = Color(0xFF0F766E);
  static const Color primarySoft = Color(0xFFE6FFFB);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color success = Color(0xFF15803D);
  static const Color danger = Color(0xFFDC2626);
  static const Color shadow = Color(0x140F172A);

  static const ColorScheme colorScheme = ColorScheme.light(
    primary: primary,
    onPrimary: Colors.white,
    secondary: Color(0xFF1D4ED8),
    surface: panel,
    error: danger,
  );
}

class AppStrings {
  static const String appTitle = 'Pulse Watchlist';
  static const String watchlist = 'Watchlist';
  static const String subtitle =
      'Track priority symbols, reorder conviction quickly, and persist state locally.';
}

class AppDurations {
  static const Duration short = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration long = Duration(milliseconds: 420);
}
