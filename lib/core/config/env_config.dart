import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class EnvConfig {
  /// Check if app is running in production (release mode)
  static bool get isProduction => kReleaseMode;

  static Future<void> load() async {
    try {
      // Først prøver vi at læse environment variablen
      const env = String.fromEnvironment('ENVIRONMENT');

      // Hvis env er tom (ikke sat via --dart-define), vælg automatisk baseret på build mode
      final fileName = env.isEmpty ? (kReleaseMode ? '.env.production' : '.env.development') : '.env.$env';

      print('🔧 Attempting to load environment file: $fileName');
      await dotenv.load(fileName: fileName);
      print('✅ Environment loaded successfully');
      print('🔑 Supabase URL: ${dotenv.env['SUPABASE_URL']}');
    } catch (e) {
      print('❌ Error loading environment: $e');
      print('⚠️ Attempting to fall back to development environment');

      try {
        await dotenv.load(fileName: '.env.development');
        print('✅ Development environment loaded successfully');
      } catch (e) {
        print('❌ Fatal error loading any environment: $e');
        rethrow;
      }
    }
  }

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
