import 'package:flutter_test/flutter_test.dart';
import 'package:scam_shield/models/fraud_report.dart';

void main() {
  group('FraudReport.normalize', () {
    test('normalizes phone numbers with country code and formatting', () {
      expect(FraudReport.normalize('+91 98765 43210', IdentifierType.phone), '9876543210');
      expect(FraudReport.normalize('98765-43210', IdentifierType.phone), '9876543210');
      expect(FraudReport.normalize('919876543210', IdentifierType.phone), '9876543210');
      expect(FraudReport.normalize('9876543210', IdentifierType.phone), '9876543210');
    });

    test('normalizes UPI IDs to lowercase, no spaces', () {
      expect(FraudReport.normalize('User@OkAxis', IdentifierType.upi), 'user@okaxis');
      expect(FraudReport.normalize(' scammer @ okhdfc ', IdentifierType.upi), 'scammer@okhdfc');
    });

    test('different formatting of the same identifier normalizes identically', () {
      final a = FraudReport.normalize('+91-98765-43210', IdentifierType.phone);
      final b = FraudReport.normalize('98765 43210', IdentifierType.phone);
      expect(a, b);
    });
  });
}
