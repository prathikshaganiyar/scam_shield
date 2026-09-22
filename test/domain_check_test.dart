import 'package:flutter_test/flutter_test.dart';
import 'package:scam_shield/models/domain_check_result.dart';

void main() {
  group('DomainCheckResult.classify', () {
    test('domain registered 5 days ago is critical', () {
      final created = DateTime.now().subtract(const Duration(days: 5));
      expect(DomainCheckResult.classify(created), DomainRisk.critical);
    });

    test('domain registered 60 days ago is high', () {
      final created = DateTime.now().subtract(const Duration(days: 60));
      expect(DomainCheckResult.classify(created), DomainRisk.high);
    });

    test('domain registered 200 days ago is medium', () {
      final created = DateTime.now().subtract(const Duration(days: 200));
      expect(DomainCheckResult.classify(created), DomainRisk.medium);
    });

    test('domain registered 3 years ago is low', () {
      final created = DateTime.now().subtract(const Duration(days: 365 * 3));
      expect(DomainCheckResult.classify(created), DomainRisk.low);
    });

    test('null creation date is unknown', () {
      expect(DomainCheckResult.classify(null), DomainRisk.unknown);
    });
  });
}
