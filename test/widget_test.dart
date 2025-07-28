// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dosify_flutter/main.dart';

void main() {
  testWidgets('App loads and displays dashboard', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: DosifyApp()));

    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // Verify that our app loads with dashboard.
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Dosify Dashboard'), findsOneWidget);
    expect(find.text('Medications'), findsOneWidget);
  });
}
