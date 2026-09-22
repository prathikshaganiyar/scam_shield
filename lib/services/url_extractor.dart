/// Extracts URLs and domains from free text.
///
/// This class is intentionally kept as a pure utility:
/// no network calls, no API calls, and easy to unit test.
class UrlExtractor {
  static final _urlPattern = RegExp(
    r'(?:https?:\/\/)?(?:www\.)?[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+(?:\/\S*)?',
    caseSensitive: false,
  );

  static final _domainPattern = RegExp(
    r'(?:https?:\/\/)?(?:www\.)?([a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+)',
    caseSensitive: false,
  );

  // Skip common legitimate platforms so we don't WHOIS-check them
  // on every scan.
  static const _skipDomains = {
    'gmail.com',
    'yahoo.com',
    'outlook.com',
    'hotmail.com',
    'rediffmail.com',
    'linkedin.com',
    'indeed.com',
    'naukri.com',
    'whatsapp.com',
    'telegram.org',
    't.me',
    'wa.me',
    'bit.ly',
    'tinyurl.com',
  };

  /// Extract complete URLs from text.
  ///
  /// Example:
  /// "Visit https://example.com/login-now"
  /// returns:
  /// ["https://example.com/login-now"]
  static List<String> extractUrls(String text) {
    final matches = _urlPattern.allMatches(text);
    final urls = <String>{};

    for (final match in matches) {
      var url = match.group(0)?.trim();

      if (url == null || url.isEmpty) continue;

      // Remove common punctuation that may appear after a URL
      // in a sentence.
      url = url.replaceFirst(RegExp(r'[.,!?;:]+$'), '');

      if (!url.startsWith('http://') &&
          !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final domainMatch = _domainPattern.firstMatch(url);
      final domain = domainMatch?.group(1)?.toLowerCase();

      if (domain == null || domain.isEmpty) continue;

      if (_skipDomains.contains(domain)) continue;

      urls.add(url);
    }

    return urls.toList();
  }

  /// Extract candidate domains for WHOIS/domain-age checking.
  static List<String> extractDomains(String text) {
    final matches = _domainPattern.allMatches(text);
    final domains = <String>{};

    for (final match in matches) {
      final domain = match.group(1)?.toLowerCase().trim();

      if (domain == null || domain.isEmpty) continue;
      if (!domain.contains('.')) continue;
      if (_skipDomains.contains(domain)) continue;

      domains.add(domain);
    }

    return domains.toList();
  }
}
