import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/url_analysis_result.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> predict(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': text,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'API request failed: ${response.statusCode} ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<UrlAnalysisResult> analyzeUrl(String url) async {
    final response = await http.post(
      Uri.parse('$baseUrl/analyze-url'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'url': url,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'URL analysis failed: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['error'] != null) {
      throw Exception(data['error']);
    }

    return UrlAnalysisResult.fromJson(data);
  }
}