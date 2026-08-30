import 'package:flutter/widgets.dart';

import 'core/services/image_picker_service.dart';
import 'core/services/ocr_service.dart';
import 'features/onboarding/data/onboarding_store.dart';
import 'features/scans/application/scans_controller.dart';

/// App-wide dependency scope.
///
/// An [InheritedWidget] that exposes the top-level services and state singletons
/// to every screen in the tree. Instead of threading constructors through many
/// widgets and routes, screens just call `AppScope.of(context)` to obtain what
/// they need. Keeps dependency wiring centralised in one place.
class AppScope extends InheritedWidget {
  /// Owns the persistent scan history.
  final ScansController scansController;

  /// Picks source images (gallery / camera).
  final ImagePickerService imagePickerService;

  /// Performs on-device text recognition.
  final OcrService ocrService;

  /// Tracks whether onboarding was already shown.
  final OnboardingStore onboardingStore;

  const AppScope({
    super.key,
    required this.scansController,
    required this.imagePickerService,
    required this.ocrService,
    required this.onboardingStore,
    required super.child,
  });

  /// Looks up the scope and registers this context as a *dependent*.
  ///
  /// Use inside `build` when the widget needs to rebuild if the scope changes.
  static AppScope of(BuildContext context) {
    final AppScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }

  /// Looks up the scope *without* registering a dependency.
  ///
  /// Use outside `build` (e.g. in callbacks, `async` methods or `initState`)
  /// where you only need the value, not a rebuild.
  static AppScope read(BuildContext context) {
    final AppScope? scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      scansController != oldWidget.scansController ||
      imagePickerService != oldWidget.imagePickerService ||
      ocrService != oldWidget.ocrService ||
      onboardingStore != oldWidget.onboardingStore;
}