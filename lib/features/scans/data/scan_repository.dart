import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/ocr_result.dart';

/// Persistence contract for scan history.
///
/// Kept as an interface so the controller can be unit-tested against an
/// in-memory fake instead of touching real device storage.
abstract interface class ScansRepository {
  /// Loads every stored scan, newest first.
  Future<List<OcrResult>> loadAll();

  /// Persists the given list of scans, replacing any previous history.
  Future<void> saveAll(List<OcrResult> scans);
}

/// [ScansRepository] backed by `shared_preferences`.
///
/// Each scan is serialised to JSON and stored as one string; the whole list
/// is kept under a single preference key. Good enough for text-sized payloads
/// and requires no native database setup.
class PrefsScansRepository implements ScansRepository {
  /// Preference key under which the JSON list is stored.
  static const String _storageKey = 'scan_history';

  /// Preferred async API for `shared_preferences`.
  final SharedPreferencesAsync _prefs;

  PrefsScansRepository({SharedPreferencesAsync? prefs})
      : _prefs = prefs ?? SharedPreferencesAsync();

  @override
  Future<List<OcrResult>> loadAll() async {
    final List<String>? raw = await _prefs.getStringList(_storageKey);
    if (raw == null) return [];

    // Parse each stored JSON string, skipping any corrupt entries so one bad
    // record can never take the whole history down.
    return raw
        .map((String entry) {
          try {
            return OcrResult.fromJson(
              jsonDecode(entry) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<OcrResult>()
        .toList();
  }

  @override
  Future<void> saveAll(List<OcrResult> scans) async {
    final List<String> raw = scans
        .map((OcrResult scan) => jsonEncode(scan.toJson()))
        .toList();
    await _prefs.setStringList(_storageKey, raw);
  }
}