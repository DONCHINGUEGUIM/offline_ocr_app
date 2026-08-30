/// Central place for every user-facing string and magic number used across
/// the app.
///
/// Keeping literals here instead of scattering them through widgets means a
/// single source of truth for things such as the app name, tag lines and
/// generic copy. UI text that is unique to one widget (e.g. a button label)
/// may stay next to that widget, but shared values belong in this file.
class AppConstants {
  AppConstants._(); // Private constructor: this class is never instantiated.

  /// Name shown in the app bar and launcher.
  static const String appName = 'Capture';

  /// Short tag line displayed on the home screen hero section.
  static const String tagline = 'Offline text recognition';

  /// Empty-state headline shown before any scan has been performed.
  static const String emptyHeadline = 'No scans yet';

  /// Empty-state body shown before any scan has been performed.
  static const String emptyBody =
      'Pick an image or take a photo and your text will appear here. '
      'Everything runs on-device.';

  /// Generic error message when OCR fails for an unknown reason.
  static const String ocrErrorMessage =
      'Could not read the text in this image. Please try another one.';
}