import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/ocr_result.dart';

/// Shows the extracted text of a completed OCR scan.
///
/// Provides read-only display plus a copy-to-clipboard action. It receives a
/// fully-constructed [OcrResult], so it performs no work of its own and can
/// stay a lightweight, purely presentational screen.
class ResultScreen extends StatelessWidget {
  /// The scan whose text should be displayed.
  final OcrResult result;

  const ResultScreen({super.key, required this.result});

  /// Copies the recognised text to the system clipboard and confirms via a
  /// snack bar.
  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: result.text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    // Empty results get a dedicated message rather than a blank page.
    final String body = result.hasText
        ? result.text
        : 'No text was recognised in this image.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan result'),
        actions: [
          IconButton(
            tooltip: 'Copy text',
            onPressed: result.hasText ? () => _copyToClipboard(context) : null,
            icon: const Icon(Icons.copy_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Extracted on ${result.capturedAt.toLocal()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            // Expandable text area: fills the screen and scrolls.
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: SelectableText(
                  body,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                        color: scheme.onSurface,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: result.hasText ? () => _copyToClipboard(context) : null,
              icon: const Icon(Icons.copy_all_outlined),
              label: const Text('Copy all text'),
            ),
          ],
        ),
      ),
    );
  }
}