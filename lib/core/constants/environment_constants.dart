/// ============================================================
/// SKIFT MILJØ HER - Ændre værdien nedenfor for at skifte database
/// ============================================================
///
/// Mulige værdier:
///   - AppEnvironment.development  → TEST database (til udvikling)
///   - AppEnvironment.test         → TEST database (til test)
///   - AppEnvironment.production   → PRODUKTION database (KUN til App Store builds!)
///
/// VIGTIGT: Sæt ALTID tilbage til 'development' før du committer kode!
///

enum AppEnvironment {
  development,
  test,
  production,
}

abstract class EnvironmentConstants {
  const EnvironmentConstants._();

  /// ⬇️⬇️⬇️ SKIFT MILJØ HER ⬇️⬇️⬇️
  static const AppEnvironment activeEnvironment = AppEnvironment.test;

  /// ⬆️⬆️⬆️ SKIFT MILJØ HER ⬆️⬆️⬆️
}

// Created: 2025-12-17
