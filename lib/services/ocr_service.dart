import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Extracts text from an uploaded photo of an offer letter/message using
/// on-device ML Kit OCR. Deliberately on-device (not a cloud OCR API):
/// no API key needed, works offline, and the image never leaves the
/// phone for the text-extraction step (it does get sent to the cloud
/// separately for the reverse-image search, which needs a server-side
/// index — that's a different, necessary trade-off, worth being upfront
/// about in the app's privacy notice).
class OcrService {
  static final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  static Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final result = await _recognizer.processImage(inputImage);
    return result.text;
  }

  static void dispose() {
    _recognizer.close();
  }
}
