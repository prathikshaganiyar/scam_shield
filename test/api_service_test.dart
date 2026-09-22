import 'package:flutter_test/flutter_test.dart';
import 'package:scam_shield/services/api_service.dart';

void main() {
  test('ScamShield API returns a prediction', () async {
    final result = await ApiService.predict(
      'Congratulations! You have been selected for a work from home job. '
      'Pay ₹999 registration fee today.',
    );

    expect(result['prediction'], 'scam');
    expect(result['risk_level'], 'medium');
    expect(result['reasons'], isNotEmpty);
  });
}