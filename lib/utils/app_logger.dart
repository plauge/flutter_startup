import 'package:logger/logger.dart';

/// Log-kategorier for at kunne filtrere log-output efter kontekst
enum LogCategory {
  gui,
  provider,
  service,
  other,
}

/// Konfiguration til at styre hvilke kategorier der logges
class LogConfig {
  static final Set<LogCategory> _enabledCategories = {
    LogCategory.gui,
    LogCategory.provider,
    LogCategory.service,
    LogCategory.other,
  };

  static bool isEnabled(LogCategory category) => _enabledCategories.contains(category);

  static void enable(LogCategory category) => _enabledCategories.add(category);

  static void disable(LogCategory category) => _enabledCategories.remove(category);

  static void setOnly(Set<LogCategory> categories) {
    _enabledCategories
      ..clear()
      ..addAll(categories);
  }
}

/// Hovedklasse som håndterer logning med præfikser
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(),
  );

  static void log(LogCategory category, String message) {
    if (LogConfig.isEnabled(category)) {
      final prefix = '[${category.name.toUpperCase()}]';
      _logger.i('$prefix $message');
    }
  }
}

/// Returnerer en lokal log-funktion bundet til en bestemt kategori
typedef ScopedLog = void Function(String message);

ScopedLog scopedLogger(LogCategory category) {
  return (String message) => AppLogger.log(category, message);
}

// Created: 2024-07-15 10:00:00 (eksempel dato/tid)
// Note: Erstat ovenstående kommentar med den faktiske dato og tid ved kørsel.
