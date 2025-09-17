import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'exports.dart';
import 'core/config/env_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'providers/firebase_messaging_provider.dart';
import 'dart:io'; // Tilføj denne import
import 'dart:developer' as developer;

// Background message handler - MUST be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background processing
  await Firebase.initializeApp();

  // Background handler bruger developer.log da app_logger ikke er tilgængelig
  final timestamp = DateTime.now().toIso8601String();
  developer.log('🌙🕒 [$timestamp] FLUTTER BACKGROUND MESSAGE 🌙', name: 'FCMBackground');
  developer.log('🍎 Platform: ${Platform.isIOS ? 'iOS' : 'Android'}', name: 'FCMBackground');
  developer.log('📝 Message ID: ${message.messageId}', name: 'FCMBackground');
  developer.log('📤 From: ${message.from}', name: 'FCMBackground');
  developer.log('📦 Data: ${message.data}', name: 'FCMBackground');

  if (message.notification != null) {
    developer.log('🔔 Title: ${message.notification!.title}', name: 'FCMBackground');
    developer.log('📄 Body: ${message.notification!.body}', name: 'FCMBackground');

    // iOS specific debugging
    if (Platform.isIOS) {
      developer.log('🍎 iOS Background Notification Data:', name: 'FCMBackground');
      developer.log('🍎   - Badge: ${message.notification!.apple?.badge}', name: 'FCMBackground');
      developer.log('🍎   - Sound: ${message.notification!.apple?.sound}', name: 'FCMBackground');
      developer.log('🍎   - ImageUrl: ${message.notification!.apple?.imageUrl}', name: 'FCMBackground');
    }
  }

  final processedTimestamp = DateTime.now().toString();
  developer.log('🌙 Flutter background message processed ($processedTimestamp)', name: 'FCMBackground');

  // Here you could:
  // - Update local database
  // - Schedule local notification
  // - Perform background sync
}

void main() async {
  final log = scopedLogger(LogCategory.gui);
  AppLogger.logSeparator('main');
  LogConfig.setOnly({
    LogCategory.gui,
    LogCategory.security,
    LogCategory.provider,
    LogCategory.service,
    LogCategory.other,
  });

  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // Lock app to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    log('📱 Starting app initialization');

    // Initialize Firebase
    await Firebase.initializeApp();
    log('🔥 Firebase initialized');

    // Set up Firebase Messaging background handler - ONLY in production/release mode
    if (kReleaseMode) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      log('🌙 Firebase background message handler registered (production)');
    } else {
      log('🚫 Firebase background message handler DISABLED (development mode)');
    }

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
      headers: {
        // Brug user-agent header da den er tilladt i Supabase logs
        'user-agent': Platform.isIOS ? 'iOS/${AppVersionConstants.appVersionIntIOS}' : 'Android/${AppVersionConstants.appVersionIntAndroid}',
      },
    );
    log('✅ Supabase initialized with custom user-agent: Platform=${Platform.isIOS ? 'iOS' : 'Android'}, Version=${Platform.isIOS ? AppVersionConstants.appVersionIntIOS : AppVersionConstants.appVersionIntAndroid}');

    // Initialize I18n Service
    log('🌐 Initializing I18n service...');
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    await I18nService().init(locale);
    log('✅ I18n service initialized');

    // Initialize FCM Token Lifecycle Service
    log('🔄 Initializing FCM token lifecycle service...');
    FCMTokenLifecycleService.instance.initialize();
    log('✅ FCM token lifecycle service initialized');

    // Initialize Realtime Lifecycle Service
    log('🔄 Initializing realtime lifecycle service...');
    RealtimeLifecycleService.instance.initialize();
    log('✅ Realtime lifecycle service initialized');

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

            // Initialize Firebase Messaging - ONLY in production/release mode
            if (kReleaseMode) {
              ref.watch(firebaseMessagingInitProvider);
            } else {
              // Log that notifications are disabled in development
              developer.log('Notifications disabled in development mode', name: 'FCMInit');
            }

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
