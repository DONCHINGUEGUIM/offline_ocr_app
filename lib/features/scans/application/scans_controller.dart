import 'package:flutter/foundation.dart';

import '../data/scan_repository.dart';
import '../domain/ocr_result.dart';

/// Central mutable state for the scan history.
///
/// A [ChangeNotifier] that owns the list of scans and syncs it to storage via
/// a [ScansRepository]. Widgets (the home screen) register as listeners and
/// rebuild automatically whenever the list changes. This keeps persistence
/// logic out of the widgets entirely.
class ScansController extends ChangeNotifier {
  final ScansRepository _repository;

  /// In-memory copy of the scans, newest first.
  List<OcrResult> _scans = [];

  /// Whether [load] has completed at least once.
  bool _loaded = false;

  ScansController(this._repository);

  /// Read-only view of the current scans (newest first).
  List<OcrResult> get scans => List.unmodifiable(_scans);

  /// True once [load] has finished so the UI can avoid flashing empty state.
  bool get isLoaded => _loaded;

  /// Loads persisted scans from the repository.
  Future<void> load() async {
    _scans = await _repository.loadAll();
    _loaded = true;
    notifyListeners();
  }

  /// Adds a new scan at the front of the list and persists it.
  Future<void> add(OcrResult result) async {
    _scans = [result, ..._scans];
    notifyListeners();
    await _repository.saveAll(_scans);
  }

  /// Removes a single scan and persists the change.
  Future<void> delete(OcrResult result) async {
    _scans = _scans.where((OcrResult s) => s != result).toList();
    notifyListeners();
    await _repository.saveAll(_scans);
  }

  /// Removes every scan.
  Future<void> clear() async {
    _scans = [];
    notifyListeners();
    await _repository.saveAll(_scans);
  }
}