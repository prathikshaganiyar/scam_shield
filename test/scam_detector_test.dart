import 'package:flutter_test/flutter_test.dart';
import 'package:scam_shield/models/scan_result.dart';
import 'package:scam_shield/services/scam_detector.dart';

void main() {
  group('ScamDetector', () {
    test('flags a classic advance-fee WhatsApp scam as risky', () {
      const msg = "Hello, I'm HR Manager at Amazon India. We have a Work From Home "
          "vacancy. Salary: 45,000/month. No experience needed. "
          "Registration fee: 999 only. Reply YES on whatsapp. Contact hr@gmail.com";
      final result = ScamDetector.scan(msg);
      expect(result.verdict, Verdict.risky);
      expect(result.flags, isNotEmpty);
      expect(result.riskScore, greaterThanOrEqualTo(55));
    });

    test('flags "selected without interview" pattern', () {
      const msg = 'Congratulations you have been selected for the Data Entry position. '
          'No interview required. Please pay the training fee to proceed.';
      final result = ScamDetector.scan(msg);
      expect(result.verdict, Verdict.risky);
    });

    test('a detailed, plausible job posting scores low', () {
      const msg = 'We are hiring a Backend Engineer with 2+ years experience in Python and '
          'PostgreSQL. Responsibilities include building APIs and maintaining CI pipelines. '
          'Requirements: strong problem-solving skills, familiarity with REST APIs. '
          'Please apply via our careers page at careers.examplecorp.com. Interview will be '
          'conducted in two rounds: technical screen and system design.';
      final result = ScamDetector.scan(msg);
      expect(result.verdict, Verdict.safe);
    });

    test('empty text produces zero score', () {
      final result = ScamDetector.scan('');
      expect(result.riskScore, 0);
      expect(result.verdict, Verdict.safe);
    });

    test('detects company/email domain mismatch', () {
      const msg = 'This is Google recruitment team. Contact us at hrgoogle@gmail.com for your offer letter.';
      final result = ScamDetector.scan(msg);
      expect(result.flags.any((f) => f.title.contains('mismatch')), isTrue);
    });
  });
}
