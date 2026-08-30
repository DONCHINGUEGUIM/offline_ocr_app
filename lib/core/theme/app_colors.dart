import 'package:flutter/material.dart';

/// Brand tokens used only for explicit on-brand gradient artwork
/// (launcher icon, splash, home logo mark).
///
/// Everything else — surfaces, text, containers — is driven by the active
/// [ColorScheme] (light / dark) via `Theme.of(context).colorScheme`, so the
/// UI adapts to the system theme and never produces jarring black/white boxes.
abstract final class AppColors {
  AppColors._();

  /// Brand indigo (seed colour for the Material scheme).
  static const Color indigo = Color(0xFF3F51B5);

  /// Brand cyan, used as the complementary end of brand gradients.
  static const Color cyan = Color(0xFF00BCD4);
}