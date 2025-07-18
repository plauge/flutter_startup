import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:idtruster/main.dart' as app;
import 'helpers/test_helpers.dart';
import 'test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Tests', () {
    testWidgets('Fuldt login flow → Home (5 sek) → Contacts (5 sek)', (WidgetTester tester) async {
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

      // Tjek at vi er kommet til terms of service siden
      TestHelpers.expectToBeOnTermsOfServiceScreen();
      print('✅ Login gennemført - nu på terms of service siden!');

      // Accepter terms of service
      await TestHelpers.acceptTermsOfService(tester);

      // Tjek at vi er kommet til home siden
      TestHelpers.expectToBeOnHomeScreen();
      print('✅ Terms accepteret - nu på home siden!');

      // Vent 5 sekunder på home siden
      print('⏳ Venter 5 sekunder på home siden...');
      await TestHelpers.waitForSeconds(tester, 5);
      print('✅ 5 sekunder på home siden gennemført!');

      // Navigér til Contacts siden
      await TestHelpers.navigateToContacts(tester);

      // Tjek at vi er kommet til Contacts siden
      TestHelpers.expectToBeOnContactsScreen();
      print('✅ Navigation til Contacts siden gennemført!');

      // Vent 5 sekunder på Contacts siden
      print('⏳ Venter 5 sekunder på Contacts siden...');
      await TestHelpers.waitForSeconds(tester, 5);
      print('✅ 5 sekunder på Contacts siden gennemført!');

      print('🎉 Fuldt test flow gennemført successfully!');
    });
  });
}
