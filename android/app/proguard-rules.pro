# ProGuard/R8 rules for the Capture release build.
#
# google_mlkit_text_recognition ships a single Android library that also
# contains code paths for the language-specific recognizers (Chinese,
# Devanagari, Japanese, Korean). Those model artifacts are NOT bundled with
# this app — we only use the Latin model — so the referenced option classes
# do not exist on the classpath at build time.
#
# R8 treats those references as "missing classes" and fails the release
# build. The referenced code paths are never executed at runtime (we always
# create the recognizer with TextRecognitionScript.latin), so suppressing the
# warnings with -dontwarn is safe.
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
