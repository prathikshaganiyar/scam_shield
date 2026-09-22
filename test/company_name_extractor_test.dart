import 'package:flutter_test/flutter_test.dart';
import 'package:scam_shield/services/company_name_extractor.dart';

void main() {
  group('CompanyNameExtractor.extract', () {
    test('extracts company from "HR Manager at X" pattern', () {
      const text = "Hello, I'm HR Manager at Amazon India. We have a vacancy.";
      expect(CompanyNameExtractor.extract(text), 'Amazon India');
    });

    test('extracts company from "welcome to X" pattern', () {
      const text = 'Welcome to TechCorp Solutions! Your onboarding starts Monday.';
      expect(CompanyNameExtractor.extract(text), 'TechCorp Solutions');
    });

    test('extracts company from "X is hiring" pattern', () {
      const text = 'GreatStart Innovations is hiring freshers for remote roles.';
      expect(CompanyNameExtractor.extract(text), 'GreatStart Innovations');
    });

    test('returns null when no recognizable pattern is present', () {
      const text = 'hey are you free tomorrow for lunch';
      expect(CompanyNameExtractor.extract(text), isNull);
    });

    test('trims trailing connector words', () {
      const text = 'Welcome to BrightPath for the';
      final result = CompanyNameExtractor.extract(text);
      expect(result, isNotNull);
      expect(result!.endsWith('for'), isFalse);
      expect(result.endsWith('the'), isFalse);
    });
  });
}
