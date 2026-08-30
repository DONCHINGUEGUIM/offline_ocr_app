/// A single OCR extraction produced by the application.
///
/// This is a *domain model*: it lives in the feature/domain layer and is
/// deliberately free of any Flutter/UI dependency. It only represents the
/// result of running optical character recognition over an image, plus enough
/// metadata to display and persist it.
class OcrResult {
  /// The fully recognised text, with line breaks preserved.
  final String text;

  /// Path to the image that was recognised.
  final String imagePath;

  /// When the OCR was performed.
  final DateTime capturedAt;

  /// Word recognition confidence reported by the engine (0.0 - 1.0).
  ///
  /// [confidence] is optional and, for the bundled ML Kit Latin model, it is
  /// not always populated. When unknown it is left as `null`.
  final double? confidence;

  const OcrResult({
    required this.text,
    required this.imagePath,
    required this.capturedAt,
    this.confidence,
  });

  /// Convenience "was anything recognised?" check used by the UI to avoid
  /// showing misleading success states.
  bool get hasText => text.trim().isNotEmpty;

  /// The first line of the text, used as a short preview in list tiles.
  String get preview {
    final String firstLine = text.trim().split('\n').first.trim();
    return firstLine.isEmpty ? '(empty)' : firstLine;
  }

  /// Serialises this model to a JSON map for persistence.
  Map<String, dynamic> toJson() => {
        'text': text,
        'imagePath': imagePath,
        'capturedAt': capturedAt.toIso8601String(),
        'confidence': confidence,
      };

  /// Rebuilds a model from a JSON map produced by [toJson].
  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      text: json['text'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      capturedAt: DateTime.tryParse(json['capturedAt'] as String? ?? '')
          ?.toLocal() ??
          DateTime.now(),
      confidence: json['confidence'] as double?,
    );
  }
}