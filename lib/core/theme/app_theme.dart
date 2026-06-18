import 'package:flutter/material.dart';

import 'app_fonts.dart';

/// Professional high-contrast dark theme for VoiceCode.
abstract final class AppTheme {
  static const Color _background = Color(0xFF0A0A0A);
  static const Color _surface = Color(0xFF141414);
  static const Color _surfaceHigh = Color(0xFF1E1E1E);
  static const Color _primary = Color(0xFF4FC3F7);
  static const Color _secondary = Color(0xFF81C784);
  static const Color _onSurface = Color(0xFFF5F5F5);
  static const Color _muted = Color(0xFF9E9E9E);

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        onPrimary: Color(0xFF001018),
        secondary: _secondary,
        onSecondary: Color(0xFF0A1A0D),
        surface: _surface,
        onSurface: _onSurface,
        error: Color(0xFFEF5350),
        outline: Color(0xFF424242),
      ),
    );

    final textTheme = AppFonts.interTextTheme(base.textTheme).apply(
      bodyColor: _onSurface,
      displayColor: _onSurface,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: _background,
        foregroundColor: _onSurface,
        elevation: 0,
        titleTextStyle: AppFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: _surfaceHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: const Color(0xFF001018),
          textStyle: AppFonts.inter(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2A2A2A)),
      hintColor: _muted,
    );
  }
}
