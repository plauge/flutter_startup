import 'exports.dart';
import 'core/config/env_config.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add deep link debugging
  print('🔗 Setting up deep link handling...');

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
    print('📱 Starting app initialization');

    // Load environment variables
    await EnvConfig.load();
    print('🌍 Environment loaded');

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    print('💾 SharedPreferences initialized');

    // Initialize Supabase
    print('🔄 Initializing Supabase with URL: ${EnvConfig.supabaseUrl}');
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      authFlowType: AuthFlowType.pkce,
      anonKey: EnvConfig.supabaseAnonKey,
      debug: true,
    );
    print('✅ Supabase initialized');

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
    print('❌ Error during app initialization: $e');
    rethrow;
  }
}

class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('''
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
