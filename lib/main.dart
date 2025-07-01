import 'exports.dart';
import 'core/config/env_config.dart';
import 'package:flutter/services.dart';
import 'services/i18n_service.dart';

void main() async {
  final log = scopedLogger(LogCategory.gui);
  AppLogger.logSeparator('main');
  LogConfig.setOnly({
    //LogCategory.gui,
    //LogCategory.security,
    // LogCategory.provider,
    LogCategory.service,
    LogCategory.other,
  });

  WidgetsFlutterBinding.ensureInitialized();

  // Add deep link debugging
  log('🔗 Setting up deep link handling...');

  // Lås orientering til portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Sæt UI til at starte fra toppen
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  try {
    log('📱 Starting app initialization');

    // Load environment variables
    await EnvConfig.load();
    log('🌍 Environment loaded');

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    log('💾 SharedPreferences initialized');

    // Initialize Supabase
    log('🔄 Initializing Supabase with URL: ${EnvConfig.supabaseUrl}');
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      authFlowType: AuthFlowType.pkce,
      anonKey: EnvConfig.supabaseAnonKey,
      debug: true,
    );
    log('✅ Supabase initialized');

    // Initialize I18n Service
    log('🌐 Initializing I18n service...');
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    await I18nService().init(locale);
    log('✅ I18n service initialized');

    runApp(
      ProviderScope(
        observers: [ProviderLogger()],
        overrides: [
          standardStorageProvider.overrideWithValue(
            StandardStorageService(prefs),
          ),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            // Add deep link listener

            ref.watch(authListenerProvider);
            return const MyApp();
          },
        ),
      ),
    );
  } catch (e) {
    log('❌ Error during app initialization: $e');
    rethrow;
  }
}

class ProviderLogger extends ProviderObserver {
  final log = scopedLogger(LogCategory.gui);
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    AppLogger.logSeparator('ProviderLogger didUpdateProvider');
    log('''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "oldValue": "$previousValue",
  "newValue": "$newValue"
}''');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.logSeparator('MyApp build');
    final router = ref.watch(appRouter);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
