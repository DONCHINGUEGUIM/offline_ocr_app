import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app_scope.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/scans_controller.dart';
import '../../domain/ocr_result.dart';
import '../widgets/action_card.dart';
import '../widgets/scan_tile.dart';
import 'result_screen.dart';

/// Main screen: the entry point for OCR actions and the persistent scan list.
///
/// Responsibilities:
///  * present the two primary actions (gallery / camera),
///  * run the pick -> OCR -> save pipeline with a loading overlay,
///  * render the saved scan history with copy/ delete actions.
///
/// All mutable history lives in the app-scoped [ScansController]; this widget
/// only re-renders it, so the list stays in sync after add/delete regardless
/// of which action triggered the change.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// True while OCR is running (shows the blocking progress overlay).
  bool _isProcessing = false;

  /// Compressed output cap passed to the image picker so large photos are
  /// resized (both in pixels and jpeg quality) before OCR. This keeps the
  /// operation fast and avoids out-of-memory errors on high-megapixel shots.
  static const double _maxDimension = 1600;
  static const int _jpegQuality = 90;

  /// Runs the full pipeline: pick image -> OCR -> persist -> show result.
  ///
  /// [fromCamera] selects the source (`false` = gallery, `true` = camera).
  Future<void> _processImage({required bool fromCamera}) async {
    // Guard against double taps while already processing.
    if (_isProcessing) return;

    final AppScope scope = AppScope.read(context);

    // 1) Let the user choose an image. `null` means they cancelled.
    final File? image = fromCamera
        ? await scope.imagePickerService.takePhoto(
            maxWidth: _maxDimension,
            maxHeight: _maxDimension,
            imageQuality: _jpegQuality,
          )
        : await scope.imagePickerService.pickFromGallery(
            maxWidth: _maxDimension,
            maxHeight: _maxDimension,
            imageQuality: _jpegQuality,
          );
    if (image == null) return;

    // 2) Block the UI with a loading overlay and run OCR.
    setState(() => _isProcessing = true);
    try {
      final OcrResult result = await scope.ocrService.recognize(image.path);
      if (!mounted) return;

      // 3) Persist the scan, then show its result screen.
      await scope.scansController.add(result);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppConstants.ocrErrorMessage)),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Copies the whole text of a scan to the system clipboard.
  Future<void> _copy(OcrResult result) async {
    await Clipboard.setData(ClipboardData(text: result.text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  /// Asks for confirmation, then deletes a single scan.
  Future<void> _confirmDelete(OcrResult result) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete this scan?'),
        content: const Text('This will permanently remove the saved text.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final ScansController controller = AppScope.read(context).scansController;
    await controller.delete(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: ListenableBuilder(
              listenable: AppScope.of(context).scansController,
              builder: (BuildContext context, _) {
                final ScansController controller =
                    AppScope.of(context).scansController;
                return ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    const _Header(),
                    const SizedBox(height: 24),
                    ActionCard(
                      icon: Icons.photo_library_outlined,
                      title: 'Gallery',
                      subtitle: 'Pick an existing image',
                      onTap: () => _processImage(fromCamera: false),
                    ),
                    const SizedBox(height: 16),
                    ActionCard(
                      icon: Icons.camera_alt_outlined,
                      title: 'Camera',
                      subtitle: 'Capture a document live',
                      onTap: () => _processImage(fromCamera: true),
                    ),
                    const SizedBox(height: 32),
                    _buildScanList(controller),
                  ],
                );
              },
            ),
          ),
          if (_isProcessing) const _ProcessingOverlay(),
        ],
      ),
    );
  }

  /// Scan-history section: a list of stored scans or an empty-state hint.
  Widget _buildScanList(ScansController controller) {
    if (!controller.isLoaded) {
      // History is still being read from storage; show nothing yet.
      return const SizedBox.shrink();
    }
    if (controller.scans.isEmpty) {
      return const _EmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Scans', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...controller.scans.map(
          (OcrResult scan) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ScanTile(
              result: scan,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ResultScreen(result: scan),
                ),
              ),
              onCopy: () => _copy(scan),
              onDelete: () => _confirmDelete(scan),
            ),
          ),
        ),
      ],
    );
  }
}

/// Brand header: app name + tagline rendered as a hero block.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.indigo, AppColors.cyan],
            ),
          ),
          child: const Icon(
            Icons.document_scanner_outlined,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          AppConstants.tagline,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// Friendly empty-state shown when there are no saved scans yet.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.manage_search_rounded,
            size: 64,
            color: scheme.outline.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            AppConstants.emptyHeadline,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.emptyBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

/// Semi-transparent overlay with a spinner shown while OCR runs.
class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      alignment: Alignment.center,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Reading text…'),
            ],
          ),
        ),
      ),
    );
  }
}