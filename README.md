# Capture — Offline OCR

Fully offline OCR app that recognises text from images and documents **on-device**. No internet required — capture a photo or pick from the gallery, extract the text, and copy/share it.

## Features

- **Camera & gallery capture** (`image_picker`)
- **On-device text recognition** (Google ML Kit) — works 100% offline
- **Scan history** stored locally (`shared_preferences`)
- **Copy / share** extracted text
- **Onboarding + splash** flow
- Dark-themed, feature-first architecture

## Tech Stack

| Area | Tech |
|------|------|
| Framework | Flutter / Dart |
| OCR | google_mlkit_text_recognition |
| Images | image_picker |
| Local storage | shared_preferences |

## Project Structure

```
lib/
├── main.dart, app.dart, app_scope.dart
├── core/
│   ├── constants/
│   ├── services/        # ocr_service, image_picker_service
│   └── theme/           # colors, theme
└── features/
    ├── onboarding/      # splash, onboarding (data + presentation)
    └── scans/           # home, result, widgets + controller/repository
```

Feature-first layout: each feature has `data/`, `application/`, `domain/`, and `presentation/` layers.

## Getting Started

### Prerequisites

- Flutter 3.x
- ML Kit works out of the box on Android/iOS (model downloads on first build)

### Run

```bash
git clone https://github.com/DONCHINGUEGUIM/offline_ocr_app.git
cd offline_ocr_app
flutter pub get
flutter run
```

### Build

```bash
flutter build apk            # Android
flutter build ios            # iOS (macOS only)
flutter build linux          # Desktop
```

## How It Works

1. User picks/captures an image
2. `OcrService` runs ML Kit text recognition entirely on-device
3. Result flows through `ScansController` → stored via `ScanRepository`
4. Result screen shows extractable, copyable text

## Author

**Donchi Ngueguim** — [github.com/DONCHINGUEGUIM](https://github.com/DONCHINGUEGUIM)

## License

MIT
