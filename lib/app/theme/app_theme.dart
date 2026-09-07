import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _emerald = Color(0xFF146B55);
  static const _night = Color(0xFF0B211C);
  static const _parchment = Color(0xFFF7F2E7);
  static const _gold = Color(0xFFC79B45);
  static const _interfaceFont = 'packages/quran_library/cairo';
  static const _fallbackFonts = [
    'packages/quran_library/naskh',
    'NotoSansBengali',
  ];

  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _emerald,
          brightness: Brightness.light,
          surface: _parchment,
        ).copyWith(
          primary: _emerald,
          secondary: _gold,
          surfaceContainer: const Color(0xFFF0EADB),
          surfaceContainerHighest: const Color(0xFFE5DDCC),
        );
    return _build(scheme);
  }

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _emerald,
          brightness: Brightness.dark,
          surface: _night,
        ).copyWith(
          primary: const Color(0xFF83D5B8),
          secondary: const Color(0xFFE1BD73),
          surfaceContainer: const Color(0xFF13332B),
          surfaceContainerHighest: const Color(0xFF1C4439),
        );
    return _build(scheme);
  }

  static ThemeData _build(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: false,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: _interfaceFont,
      fontFamilyFallback: _fallbackFonts,
      textTheme: Typography.material2021().black.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
        fontFamily: _interfaceFont,
        fontFamilyFallback: _fallbackFonts,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      dividerColor: scheme.outline.withValues(alpha: 0.18),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.14),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(
          fontFamily: _interfaceFont,
          color: scheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
