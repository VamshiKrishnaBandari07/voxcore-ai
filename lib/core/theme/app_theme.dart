import 'package:flutter/material.dart';

import '../theme/app_fonts.dart';

abstract final class AppTheme {
  static const Color background = Color(0xFF08080C);
  static const Color surface = Color(0xFF12121A);
  static const Color surfaceHigh = Color(0xFF1A1A24);
  static const Color primary = Color(0xFF5CE1E6);
  static const Color secondary = Color(0xFF7CFFB2);
  static const Color accent = Color(0xFF9B8CFF);
  static const Color onSurface = Color(0xFFF4F4F8);
  static const Color muted = Color(0xFF8B8B9A);
  static const Color border = Color(0xFF2A2A38);

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: primary,
      onPrimary: Color(0xFF001014),
      secondary: secondary,
      onSecondary: Color(0xFF001408),
      tertiary: accent,
      surface: surface,
      onSurface: onSurface,
      error: Color(0xFFFF6B6B),
      outline: border,
    );

    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark, colorScheme: scheme);
    final textTheme = AppFonts.interTextTheme(base.textTheme).apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withOpacity(0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? primary : muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? primary : muted, size: 24);
        }),
      ),
      cardTheme: CardThemeData(
        color: surfaceHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF001014),
          textStyle: AppFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: surfaceHigh,
          foregroundColor: onSurface,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: border),
      hintColor: muted,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceHigh,
        contentTextStyle: AppFonts.inter(color: onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
