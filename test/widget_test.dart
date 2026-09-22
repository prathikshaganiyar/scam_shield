import 'package:flutter_test/flutter_test.dart';
import 'package:scam_shield/main.dart';

void main() {
  testWidgets(
    'ScamShield app loads successfully',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ScamShieldApp(),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Analyze a message'),
        findsOneWidget,
      );

      expect(
        find.text('Check for Scam Signs'),
        findsOneWidget,
      );
    },
  );
}
