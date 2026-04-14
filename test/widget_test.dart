import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:coolapp/screens/ml_modules/meal_page.dart';

void main() {
  testWidgets('Meal page renders prediction form', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MealPage()));

    expect(find.text('Meal Recommendation'), findsOneWidget);
    expect(find.text('Predict Meal'), findsOneWidget);
  });
}
