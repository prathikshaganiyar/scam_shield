import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import '../models/domain_check_result.dart';

/// Looks up domain registration data via whoisjson.com's free-tier API.
/// If you switch providers, this is the only file that needs to change —
/// callers just get back a [DomainCheckResult] regardless of provider.
class DomainCheckService {
  static const _baseUrl = 'https://whoisjson.com/api/v1/whois';

  static Future<DomainCheckResult> check(String domain) async {
    if (ApiKeys.whoisApiKey == 'YOUR_WHOIS_API_KEY_HERE') {
      return DomainCheckResult.error(
        domain,
        'WHOIS API key not configured — see lib/config/api_keys.dart',
      );
    }

    try {
      final uri = Uri.parse('$_baseUrl?domain=$domain');
      final response = await http
          .get(uri, headers: {'Authorization': 'Token=${ApiKeys.whoisApiKey}'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return DomainCheckResult.error(domain, 'Lookup failed (HTTP ${response.statusCode})');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final createdRaw = data['created'] as String?;
      final createdDate = createdRaw != null ? DateTime.tryParse(createdRaw) : null;
      final registrar = data['registrar']?['name'] as String?;

      return DomainCheckResult(
        domain: domain,
        createdDate: createdDate,
        registrar: registrar,
        risk: DomainCheckResult.classify(createdDate),
      );
    } catch (e) {
      return DomainCheckResult.error(domain, 'Couldn\'t reach WHOIS service. Check your connection.');
    }
  }

  static Future<List<DomainCheckResult>> checkAll(List<String> domains) async {
    return Future.wait(domains.map(check));
  }
}
