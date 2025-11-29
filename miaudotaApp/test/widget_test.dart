// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// Material import is not required in this test; keeping minimal imports
import 'package:flutter_test/flutter_test.dart';

import 'package:miaudota_app/main.dart';

void main() {
  testWidgets('App shows splash text', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MiaudotaApp());
    await tester.pump();

    // Verify the splash text is shown
    expect(find.text('Conectando lares a patinhas...'), findsOneWidget);

    // Advance time to let the splash timer run and avoid pending timers at the end
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
