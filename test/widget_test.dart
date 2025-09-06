import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecofinds/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EcoFindsApp());

    // Verify that the app title is present.
    expect(find.text('EcoFinds'), findsOneWidget);

    // Further tests can be added here to check for specific widgets or text on the home screen.
    // For example, if you want to check for the login screen's presence after the loading indicator.
    await tester.pumpAndSettle(); // Wait for all animations and async operations to complete.
    // It's not guaranteed that the login screen will appear instantly due to the async nature.
    // So, we'll test for a widget that's likely to be on the login screen.
    // For example, if your LoginScreen has a "Login" button.
    // expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });
}