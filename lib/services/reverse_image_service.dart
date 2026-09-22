import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import '../models/image_forensics_result.dart';

/// Reverse-searches an uploaded image (offer letter, logo) via Google
/// Cloud Vision's Web Detection feature. This finds other pages on the
/// web where visually similar or identical images appear — a concrete,
/// checkable fact ("this exact image appears on 30 unrelated sites")
/// versus a chatbot's impression from looking at one screenshot once.
class ReverseImageService {
  static const _baseUrl = 'https://vision.googleapis.com/v1/images:annotate';

  static Future<ImageForensicsResult> checkImage(Uint8List imageBytes) async {
    if (ApiKeys.visionApiKey == 'YOUR_GOOGLE_CLOUD_VISION_API_KEY_HERE') {
      return ImageForensicsResult.error(
        'Vision API key not configured — see lib/config/api_keys.dart',
      );
    }

    try {
      final base64Image = base64Encode(imageBytes);
      final uri = Uri.parse('$_baseUrl?key=${ApiKeys.visionApiKey}');
      final body = jsonEncode({
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'WEB_DETECTION', 'maxResults': 20}
            ],
          }
        ]
      });

      final response = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return ImageForensicsResult.error('Lookup failed (HTTP ${response.statusCode})');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final responses = data['responses'] as List<dynamic>?;
      if (responses == null || responses.isEmpty) {
        return ImageForensicsResult.error('No response from image search.');
      }

      final webDetection = responses.first['webDetection'] as Map<String, dynamic>?;
      if (webDetection == null) {
        return ImageForensicsResult(matchCount: 0, matchingDomains: [], risk: ImageForensicsRisk.clean);
      }

      final fullMatches = webDetection['fullMatchingImages'] as List<dynamic>? ?? [];
      final partialMatches = webDetection['partialMatchingImages'] as List<dynamic>? ?? [];
      final pagesWithImage = webDetection['pagesWithMatchingImages'] as List<dynamic>? ?? [];

      final domains = pagesWithImage
          .map((p) {
            final url = p['url'] as String?;
            if (url == null) return null;
            final uri = Uri.tryParse(url);
            return uri?.host;
          })
          .whereType<String>()
          .toSet()
          .toList();

      final matchCount = fullMatches.length + partialMatches.length;

      return ImageForensicsResult(
        matchCount: matchCount,
        matchingDomains: domains,
        risk: ImageForensicsResult.classify(matchCount),
      );
    } catch (e) {
      return ImageForensicsResult.error('Couldn\'t reach image search service. Check your connection.');
    }
  }
}
