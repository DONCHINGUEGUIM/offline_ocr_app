import 'dart:io';

import 'package:image_picker/image_picker.dart';

/// Abstract contract for picking a source image to OCR.
///
/// Declared as an interface so the UI does not depend directly on the
/// `image_picker` plugin. This keeps widgets easy to test and makes it trivial
/// to swap the implementation later (e.g. for a file picker).
abstract interface class ImagePickerService {
  /// Asks the user to pick an existing image from the gallery.
  ///
  /// [maxWidth], [maxHeight] and [imageQuality] optionally resize/compress
  /// the picked image so large photos do not exhaust memory during OCR.
  Future<File?> pickFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  });

  /// Captures a photo with the device camera.
  ///
  /// Same optional [maxWidth], [maxHeight] and [imageQuality] controls as
  /// [pickFromGallery].
  Future<File?> takePhoto({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  });
}

/// Concrete [ImagePickerService] backed by the `image_picker` package.
///
/// The plugin handles all platform-specific glue (Android photo picker, iOS
/// image picker, camera permission prompts), so the rest of the app stays
/// platform agnostic.
class GalleryImagePickerService implements ImagePickerService {
  /// The underlying `image_picker` plugin instance.
  final ImagePicker _imagePicker;

  GalleryImagePickerService([ImagePicker? imagePicker])
      : _imagePicker = imagePicker ?? ImagePicker();

  @override
  Future<File?> pickFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      // Skip EXIF metadata fetch — faster and avoids large-content errors on
      // some devices.
      requestFullMetadata: false,
    );
    // `null` means the user cancelled the picker, which we pass through.
    return image == null ? null : File(image.path);
  }

  @override
  Future<File?> takePhoto({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      requestFullMetadata: false,
    );
    return file == null ? null : File(file.path);
  }
}