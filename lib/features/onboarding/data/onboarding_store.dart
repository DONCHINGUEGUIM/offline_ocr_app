import 'package:shared_preferences/shared_preferences.dart';

/// Persists the "has the user already been onboarded?" flag.
///
/// The onboarding screens are shown only once, on first launch. This small
/// store reads/writes that flag via `shared_preferences`.
class OnboardingStore {
  /// Preference key holding the completion flag.
  static const String _key = 'has_seen_onboarding';

  final SharedPreferencesAsync _prefs;

  OnboardingStore({SharedPreferencesAsync? prefs})
      : _prefs = prefs ?? SharedPreferencesAsync();

  /// True if the user has already finished the onboarding flow.
  Future<bool> get hasCompleted async => await _prefs.getBool(_key) ?? false;

  /// Marks onboarding as finished so it won't be shown again.
  Future<void> complete() => _prefs.setBool(_key, true);
}