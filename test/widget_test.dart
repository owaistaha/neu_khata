import 'package:flutter_test/flutter_test.dart';

import 'package:neu_khata/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    // Build the app (without Isar, so we test just the widget tree).
    await tester.pumpWidget(const KhataDigitalApp());

    // Verify the app title is rendered somewhere.
    expect(find.text('Khata Digital'), findsOneWidget);
  });
}
