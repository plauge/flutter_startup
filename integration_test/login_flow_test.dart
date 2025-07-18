import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:idtruster/main.dart' as app;
import 'helpers/test_helpers.dart';
import 'test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Tests', () {
    testWidgets('Login flow → Home (5 sek)', (WidgetTester tester) async {
      // Start appen
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Debug: Print alle tekster på skærmen for at se hvad der er tilgængeligt
      print('=== Tekster på login skærmen ===');
      TestHelpers.debugPrintAllTexts(tester);

      // Tjek at vi er på login skærmen
      TestHelpers.expectToBeOnLoginScreen();

      // Navigér til email/password login skærm
      await TestHelpers.navigateToEmailPasswordLogin(tester);

      // Tjek at vi er kommet til email/password skærmen
      TestHelpers.expectToBeOnEmailPasswordScreen();

      print('✅ Navigation til email/password skærm gennemført!');

      // Udfør login
      await TestHelpers.performLogin(tester);

      // Vent på navigation efter login
      print('⏳ Venter på navigation efter login...');
      await TestHelpers.waitForSeconds(tester, 3);

      // Tjek om vi er på Terms of Service siden (kun første gang bruger)
      final isOnTermsScreen = TestHelpers.tryExpectToBeOnTermsOfServiceScreen();

      if (isOnTermsScreen) {
        print('✅ Første gang bruger - på Terms of Service siden!');

        // Accepter terms of service
        await TestHelpers.acceptTermsOfService(tester);
        print('✅ Terms accepteret!');
      } else {
        print('✅ Ikke første gang bruger - springer Terms of Service over');
      }

      // Nu skal vi være på home siden
      TestHelpers.expectToBeOnHomeScreen();
      print('✅ Login gennemført - nu på Home siden!');

      // Vent 5 sekunder på home siden
      print('⏳ Venter 5 sekunder på Home siden...');
      await TestHelpers.waitForSeconds(tester, 5);
      print('✅ 5 sekunder på Home siden gennemført!');

      print('🎉 Login test gennemført successfully!');
    });
  });
}
