// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmshift_mobile/main.dart';
import 'package:farmshift_mobile/services/auth_service.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Create a mock auth service for testing
    final mockAuthService = AuthService();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(authService: mockAuthService));

    // Verify that login screen appears
    expect(find.text('Welcome to FarmShift'), findsOneWidget);
    expect(find.byType(TextFormField), findsAtLeast(1));
  });
}
