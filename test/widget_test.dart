// Smoke tests for the Capture app's home screen.
//
// The home screen pulls its dependencies from AppScope, so these tests mount
// it with an in-memory fake repository and stub services — no real plugins,
// storage or ML Kit are touched.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:capture/app_scope.dart';
import 'package:capture/core/services/image_picker_service.dart';
import 'package:capture/core/services/ocr_service.dart';
import 'package:capture/features/onboarding/data/onboarding_store.dart';
import 'package:capture/features/scans/application/scans_controller.dart';
import 'package:capture/features/scans/data/scan_repository.dart';
import 'package:capture/features/scans/domain/ocr_result.dart';
import 'package:capture/features/scans/presentation/screens/home_screen.dart';

/// In-memory repository so no real storage is accessed.
class _FakeScansRepository implements ScansRepository {
  List<OcrResult> _items = [];

  @override
  Future<List<OcrResult>> loadAll() async => _items;

  @override
  Future<void> saveAll(List<OcrResult> scans) async => _items = List.of(scans);
}

/// Stub picker that always "cancels" (returns null, as if the user backed out).
class _StubImagePickerService implements ImagePickerService {
  @override
  Future<File?> pickFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async =>
      null;

  @override
  Future<File?> takePhoto({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async =>
      null;
}

/// Stub OCR service that returns a fixed result, never touching ML Kit.
class _StubOcrService implements OcrService {
  @override
  Future<OcrResult> recognize(String imagePath) async => OcrResult(
        text: 'Hello from OCR',
        imagePath: imagePath,
        capturedAt: DateTime.now(),
      );
}

void main() {
  // Back the async SharedPreferences API with an in-memory store so no real
  // plugin is needed during tests.
  setUpAll(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('Home screen shows app name, scan actions and empty state',
      (WidgetTester tester) async {
    // Pre-load an empty, already-loaded controller.
    final ScansController controller =
        ScansController(_FakeScansRepository());
    await controller.load();

    await tester.pumpWidget(
      AppScope(
        scansController: controller,
        imagePickerService: _StubImagePickerService(),
        ocrService: _StubOcrService(),
        onboardingStore: OnboardingStore(prefs: SharedPreferencesAsync()),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Brand header, both primary actions and the empty-state hint appear.
    expect(find.text('Capture'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('No scans yet'), findsOneWidget);
  });

  testWidgets('Saved scans render with copy and delete actions',
      (WidgetTester tester) async {
    final ScansController controller = ScansController(_FakeScansRepository());
    await controller.load();
    await controller.add(
      OcrResult(
        text: 'First scan preview',
        imagePath: '/tmp/fake.png',
        capturedAt: DateTime(2026, 1, 1),
      ),
    );

    await tester.pumpWidget(
      AppScope(
        scansController: controller,
        imagePickerService: _StubImagePickerService(),
        ocrService: _StubOcrService(),
        onboardingStore: OnboardingStore(prefs: SharedPreferencesAsync()),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // The scan preview, plus its copy and delete icons are visible.
    expect(find.text('First scan preview'), findsOneWidget);
    expect(find.byIcon(Icons.copy_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });
}