import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../features/scans/domain/ocr_result.dart';

/// Abstract contract for running OCR over an image.
///
/// The home screen depends on this interface rather than on ML Kit directly,
/// which keeps the UI decoupled from the OCR engine and simplifies testing.
abstract interface class OcrService {
  /// Recognises text from the image at [imagePath].
  ///
  /// Returns an [OcrResult] containing the extracted text. Throws on failure.
  Future<OcrResult> recognize(String imagePath);
}

  /// Concrete [OcrService] backed by Google's on-device ML Kit recognizer.
  ///
  /// ML Kit's text recognizer runs fully offline: the recognition model is
  /// bundled (or downloaded once) onto the device and no network calls are
  /// made. This satisfies the app's core requirement of working completely
  /// offline.
class MlKitOcrService implements OcrService {
  final TextRecognizer _recognizer;

  MlKitOcrService()
      : _recognizer = TextRecognizer(
          // Latin script model. Bundled with the app for the default Google
          // ML Kit install, so recognition works without internet access.
          script: TextRecognitionScript.latin,
        );

  @override
  Future<OcrResult> recognize(String imagePath) async {
    // Feed the image at the given path into the recognizer.
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognised = await _recognizer.processImage(inputImage);

    // Build the result text by joining each translated line. Iterating
    // over `block -> line` keeps the logical grouping (paragraphs) intact,
    // which produces much more readable output than a flat join.
    String text = '';
    for (final TextBlock block in recognised.blocks) {
      for (final TextLine line in block.lines) {
        if (text.isNotEmpty) text += '\n';
        text += line.text;
      }
    }

    return OcrResult(text: text, imagePath: imagePath, capturedAt: DateTime.now());
  }

  /// Releases the underlying native recognizer.
  ///
  /// Must be called when the service is no longer needed to free memory.
  Future<void> dispose() => _recognizer.close();
}