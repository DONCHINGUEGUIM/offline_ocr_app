import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds the [ThemeData] used across the whole app.
///
/// Both light and dark themes are seeded from the brand indigo, so the app
/// feels like one product regardless of the system theme. All component
/// colours are derived from the active [ColorScheme] rather than hardcoded,
/// which keeps the surfaces, text and accents coherent in both modes.
class AppTheme {
  AppTheme._(); // Private constructor: this class is never instantiated.

  /// Light mode, seeded from the brand indigo.
  static ThemeData light() =>
      _build(ColorScheme.fromSeed(seedColor: AppColors.indigo));

  /// Dark mode, seeded from the brand indigo.
  static ThemeData dark() => _build(
        ColorScheme.fromSeed(
          seedColor: AppColors.indigo,
          brightness: Brightness.dark,
        ),
      );

  /// Shared theme construction so light/dark themes stay in sync.
  static ThemeData _build(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Scaffold surface follows the scheme (light or dark) automatically.
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        // A subtle border makes cards read as harmonious panels instead of
        // floating white/black blocks.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}