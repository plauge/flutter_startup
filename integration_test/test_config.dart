/// Test konfiguration for integration tests
class TestConfig {
  // Test credentials
  static const String testEmail = 'lauge+api@pixelhuset.dk';
  static const String testPassword = '0123456789';

  // Test miljø konfiguration
  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration navigationTimeout = Duration(seconds: 5);
}
