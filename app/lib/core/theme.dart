import 'package:flutter/material.dart';

/// Material 3 themes built from anacoo.live's own palette, so the app and the
/// website read as one shop: warm paper and terracotta in the light theme, and
/// the site's near-black with its pink neon accent in the dark one.
class AnacooTheme {
  const AnacooTheme._();

  // Light — anacoo.live's paper/ink/gold.
  static const Color _paper = Color(0xFFF4EFE4);
  static const Color _paperRaised = Color(0xFFFBF7EE);
  static const Color _ink = Color(0xFF262219);
  static const Color _inkSoft = Color(0xFF6A6354);
  static const Color _line = Color(0xFFD8CFBC);
  static const Color _gold = Color(0xFFB0653C);
  static const Color _goldDeep = Color(0xFF8C4A26);

  // Dark — the site's night palette.
  static const Color _night = Color(0xFF14160F);
  static const Color _nightRaised = Color(0xFF1C1F16);
  static const Color _cream = Color(0xFFECE6D6);
  static const Color _creamSoft = Color(0xFFADA793);
  static const Color _nightLine = Color(0xFF2E3327);
  static const Color _neon = Color(0xFFFF3DAE);
  static const Color _neonSoft = Color(0xFFFF8AD8);

  /// Rush jobs and overdue items borrow the same accent in both themes.
  static const Color rush = Color(0xFFD2691E);

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: _gold,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFF0DCCC),
      onPrimaryContainer: _goldDeep,
      secondary: _goldDeep,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFEAE2D1),
      onSecondaryContainer: _ink,
      tertiary: Color(0xFF5F6B4E),
      onTertiary: Colors.white,
      error: Color(0xFFA5271B),
      onError: Colors.white,
      surface: _paper,
      onSurface: _ink,
      surfaceContainerLowest: _paperRaised,
      surfaceContainerLow: _paperRaised,
      surfaceContainer: Color(0xFFEFE9DC),
      surfaceContainerHigh: Color(0xFFEAE2D1),
      surfaceContainerHighest: Color(0xFFE4DBC8),
      onSurfaceVariant: _inkSoft,
      outline: _line,
      outlineVariant: Color(0xFFE8E1D1),
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _neon,
      onPrimary: Color(0xFF23060F),
      primaryContainer: Color(0xFF4A1030),
      onPrimaryContainer: _neonSoft,
      secondary: _neonSoft,
      onSecondary: Color(0xFF23060F),
      secondaryContainer: Color(0xFF33241C),
      onSecondaryContainer: _cream,
      tertiary: Color(0xFF9FB08A),
      onTertiary: Color(0xFF14160F),
      error: Color(0xFFFF8A80),
      onError: Color(0xFF3A0906),
      surface: _night,
      onSurface: _cream,
      surfaceContainerLowest: Color(0xFF10120B),
      surfaceContainerLow: _nightRaised,
      surfaceContainer: Color(0xFF20241A),
      surfaceContainerHigh: Color(0xFF262B1E),
      surfaceContainerHighest: Color(0xFF2C3223),
      onSurfaceVariant: _creamSoft,
      outline: _nightLine,
      outlineVariant: Color(0xFF1F2318),
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
