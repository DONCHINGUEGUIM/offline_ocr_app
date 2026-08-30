import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'core/constants/app_constants.dart';
import 'core/services/image_picker_service.dart';
import 'core/services/ocr_service.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/data/onboarding_store.dart';
import 'features/onboarding/presentation/screens/splash_screen.dart';
import 'features/scans/application/scans_controller.dart';
import 'features/scans/data/scan_repository.dart';

/// Root widget of the Capture app.
///
/// Creates the single app-wide services/state instances, loads persisted
/// scan history, and provides them to the whole tree via [AppScope]. The UI
/// then begins at the [SplashScreen], which routes to onboarding or home.
class CaptureApp extends StatefulWidget {
  const CaptureApp({super.key});

  @override
  State<CaptureApp> createState() => _CaptureAppState();
}

class _CaptureAppState extends State<CaptureApp> {
  /// Owns the persistent scan history.
  late final ScansController _scansController;

  /// Tracks first-run onboarding state.
  late final OnboardingStore _onboardingStore;

  @override
  void initState() {
    super.initState();
    // Wire the repository into the controller and start loading history so it
    // is ready (or nearly so) by the time the user reaches the home screen.
    _scansController = ScansController(PrefsScansRepository());
    _scansController.load();
    _onboardingStore = OnboardingStore();
  }

  @override
  void dispose() {
    _scansController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The scope sits above MaterialApp so every route can resolve services.
    return AppScope(
      scansController: _scansController,
      imagePickerService: GalleryImagePickerService(),
      ocrService: MlKitOcrService(),
      onboardingStore: _onboardingStore,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const SplashScreen(),
      ),
    );
  }
}