import 'package:flutter/material.dart';

import 'app.dart';

/// Entry point of the Capture (offline OCR) application.
///
/// This function is intentionally kept as small as possible: the only thing
/// it does is bootstrap Flutter and mount the root [CaptureApp] widget.
/// Keeping initialisation (themes, routing, services) inside `App` keeps this
/// file clean and makes the app easier to test.
void main() {
  // `ensureInitialized` guarantees the Flutter binding is ready before we
  // start the UI. This is important on some platforms (e.g. desktop/web)
  // when plugins are used during startup.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CaptureApp());
}