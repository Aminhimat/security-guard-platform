import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guard_app/main.dart';

void main() {
  testWidgets('Security Guard App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SecurityGuardApp());

    // Verify that our app has the login screen elements.
    expect(find.text('Security Guard'), findsOneWidget);
    expect(find.text('Management Platform'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Login form validation test', (WidgetTester tester) async {
    await tester.pumpWidget(const SecurityGuardApp());

    // Tap the login button without entering any data
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify validation messages appear
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });
}
