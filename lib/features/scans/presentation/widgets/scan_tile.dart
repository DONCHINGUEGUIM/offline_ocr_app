import 'package:flutter/material.dart';

import '../../domain/ocr_result.dart';

/// A single row in the scan-history list.
///
/// Shows a short preview of the text and the timestamp, and offers copy and
/// delete actions. The whole tile is tappable to open the full result.
class ScanTile extends StatelessWidget {
  /// The scan being displayed.
  final OcrResult result;

  /// Called when the tile body is tapped (open the full result).
  final VoidCallback onTap;

  /// Called when the copy icon is pressed.
  final VoidCallback onCopy;

  /// Called when the delete icon is pressed.
  final VoidCallback onDelete;

  const ScanTile({
    super.key,
    required this.result,
    required this.onTap,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Small leading icon that visually distinguishes the tile,
              // using a complimentary container tone from the scheme.
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: scheme.secondaryContainer,
                ),
                child: Icon(
                  Icons.notes_rounded,
                  color: scheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: scheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${result.capturedAt.toLocal()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Copy text',
                onPressed: result.hasText ? onCopy : null,
                icon: const Icon(Icons.copy_outlined),
                color: scheme.primary,
              ),
              IconButton(
                tooltip: 'Delete scan',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}