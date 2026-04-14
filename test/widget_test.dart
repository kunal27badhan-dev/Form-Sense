import 'package:flutter_test/flutter_test.dart';

import 'package:coolapp/main.dart';

void main() {
  testWidgets('App starts and loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FormSenseApp());

    // Verify app loads without errors
    expect(find.byType(FormSenseApp), findsOneWidget);
  });
}
