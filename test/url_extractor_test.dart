import 'package:flutter_test/flutter_test.dart';
import 'package:scam_shield/services/url_extractor.dart';

void main() {
  group('UrlExtractor.extractDomains', () {
    test('extracts a plain domain from message text', () {
      const text = 'Apply now at totallyrealcareers.com to get started!';
      expect(UrlExtractor.extractDomains(text), contains('totallyrealcareers.com'));
    });

    test('extracts domain from a full https URL, ignoring path', () {
      const text = 'Visit https://fakejobsindia.co.in/apply?ref=123 today.';
      expect(UrlExtractor.extractDomains(text), contains('fakejobsindia.co.in'));
    });

    test('strips www prefix', () {
      const text = 'See www.suspiciousdomain.net for details.';
      expect(UrlExtractor.extractDomains(text), contains('suspiciousdomain.net'));
    });

    test('skips common legitimate platforms', () {
      const text = 'Contact us on gmail.com or check our linkedin.com profile.';
      final domains = UrlExtractor.extractDomains(text);
      expect(domains, isNot(contains('gmail.com')));
      expect(domains, isNot(contains('linkedin.com')));
    });

    test('returns empty list when no domains present', () {
      const text = 'This message has no links at all, just plain text.';
      expect(UrlExtractor.extractDomains(text), isEmpty);
    });

    test('deduplicates repeated domains', () {
      const text = 'Go to scamsite.com now! Really, scamsite.com is great, visit www.scamsite.com';
      expect(UrlExtractor.extractDomains(text).length, 1);
    });
  });
}
