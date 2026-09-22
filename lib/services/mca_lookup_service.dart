import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import '../models/company_check_result.dart';

/// Verifies a company name against MCA (Ministry of Corporate Affairs)
/// records via eKYCnow's API. This is a genuine fact-check a chatbot can't
/// do — it either finds a real, currently-registered company or it
/// doesn't, based on live government-sourced data, not a guess from
/// training data.
///
/// Note the free tier is 5 checks total, not monthly — this is fine for
/// building and demoing, but be explicit about that limit if you ever
/// pitch this as a real product (see README "Known limitations").
/// Note: the exact endpoint path and response field names here are based
/// on typical KYB API conventions, not a verified copy of eKYCnow's
/// current docs — confirm the real request/response shape at
/// https://ekycnow.com (or whichever provider you pick) before relying
/// on this, and adjust the field names below to match. Same caveat
/// applies to any MCA API vendor, since none of them are a stable public
/// standard the way, say, a REST convention would be.
class McaLookupService {
  static const _baseUrl = 'https://api.ekycnow.com/api/v2/mca/company-search';

  static Future<CompanyCheckResult> check(String companyName) async {
    if (ApiKeys.mcaApiKey == 'YOUR_EKYCNOW_API_KEY_HERE') {
      return CompanyCheckResult.error(
        companyName,
        'MCA API key not configured — see lib/config/api_keys.dart',
      );
    }

    try {
      final uri = Uri.parse(_baseUrl);
      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer ${ApiKeys.mcaApiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'company_name': companyName}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 404) {
        return CompanyCheckResult.notFound(companyName);
      }
      if (response.statusCode != 200) {
        return CompanyCheckResult.error(companyName, 'Lookup failed (HTTP ${response.statusCode})');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) {
        return CompanyCheckResult.notFound(companyName);
      }

      final best = results.first as Map<String, dynamic>;
      return CompanyCheckResult(
        queriedName: companyName,
        status: CompanyStatus.registered,
        matchedLegalName: best['company_name'] as String?,
        cin: best['cin'] as String?,
        registrationDate: best['date_of_registration'] as String?,
      );
    } catch (e) {
      return CompanyCheckResult.error(companyName, 'Couldn\'t reach MCA lookup service. Check your connection.');
    }
  }
}
