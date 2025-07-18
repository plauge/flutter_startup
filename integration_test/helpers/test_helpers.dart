import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../test_config.dart';

/// Helper klasse til genbrugelig test-funktionalitet
class TestHelpers {
  /// Venter på at appen er fuldt loadet
  static Future<void> waitForAppToLoad(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  /// Navigerer til login skærmen med email/password
  static Future<void> navigateToEmailPasswordLogin(WidgetTester tester) async {
    final loginWithPasswordButton = find.text('Login with email + password');
    expect(loginWithPasswordButton, findsOneWidget);
    await tester.tap(loginWithPasswordButton);
    await tester.pumpAndSettle();
  }

  /// Udfører login med test credentials
  static Future<void> performLogin(WidgetTester tester) async {
    // Find email og password felter
    final emailField = find.byKey(const Key('login_email_field'));
    final passwordField = find.byKey(const Key('login_password_field'));

    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);

    // Indtast email og password
    await tester.enterText(emailField, TestConfig.testEmail);
    await tester.enterText(passwordField, TestConfig.testPassword);

    // Find og tryk på login knappen - vi finder ElevatedButton der indeholder "Login" tekst
    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);

    // Vent på login processen
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Navigerer til Contacts siden
  static Future<void> navigateToContacts(WidgetTester tester) async {
    // Find Contacts kort/knap på home siden
    final contactsCard = find.text('Contacts');
    expect(contactsCard, findsOneWidget);
    await tester.tap(contactsCard);
    await tester.pumpAndSettle();
  }

  /// Venter i et specifikt antal sekunder
  static Future<void> waitForSeconds(WidgetTester tester, int seconds) async {
    await tester.pump(Duration(seconds: seconds));
    await tester.pumpAndSettle();
  }

  /// Checker om vi er på login skærmen
  static void expectToBeOnLoginScreen() {
    expect(find.text('Select access'), findsOneWidget);
  }

  /// Checker om vi er på email/password login skærmen
  static void expectToBeOnEmailPasswordScreen() {
    expect(find.byKey(const Key('login_email_field')), findsOneWidget);
  }

  /// Accepter terms of service
  static Future<void> acceptTermsOfService(WidgetTester tester) async {
    // Find og tryk på checkbox for at acceptere terms
    final checkbox = find.byType(Checkbox);
    expect(checkbox, findsOneWidget);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Find og tryk på Agree knappen
    final agreeButton = find.widgetWithText(ElevatedButton, 'Agree');
    expect(agreeButton, findsOneWidget);
    await tester.tap(agreeButton);
    await tester.pumpAndSettle();
  }

  /// Checker om vi er på Terms of Service siden
  static void expectToBeOnTermsOfServiceScreen() {
    expect(find.text('Your Email is confirmed'), findsOneWidget);
  }

  /// Checker om vi er på home siden
  static void expectToBeOnHomeScreen() {
    // Home siden har specifikke cards med tekster
    expect(find.text('Email & Text Messages'), findsOneWidget);
  }

  /// Checker om vi er på Contacts siden
  static void expectToBeOnContactsScreen() {
    // Contacts siden har en FloatingActionButton og ingen "Email & Text Messages" tekst
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Email & Text Messages'), findsNothing);
  }

  /// Debug funktion til at printe alle tekster på skærmen
  static void debugPrintAllTexts(WidgetTester tester) {
    final textWidgets = find.byType(Text);
    for (int i = 0; i < textWidgets.evaluate().length; i++) {
      try {
        final textWidget = tester.widget<Text>(textWidgets.at(i));
        print('Text $i: ${textWidget.data}');
      } catch (e) {
        print('Text $i: Could not get text data');
      }
    }
  }
}

// Updated on 2024-12-28 at 22:30
