import 'package:flutter/material.dart';

/// Shared typography — system UI font (works offline on Windows).
abstract final class AppFonts {
  static const String _family = 'Segoe UI';

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    Color? backgroundColor,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    return TextStyle(
      fontFamily: _family,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      backgroundColor: backgroundColor,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }

  static TextStyle mono({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    Color? backgroundColor,
  }) {
    return TextStyle(
      fontFamily: 'Consolas',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      backgroundColor: backgroundColor,
    );
  }

  static TextTheme interTextTheme(TextTheme base) {
    return base.apply(fontFamily: _family);
  }
}
