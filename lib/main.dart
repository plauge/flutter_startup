import 'exports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialiser Supabase
  await Supabase.initialize(
    url: 'https://tbhdoacerawlyozuwbdl.supabase.co',
    authFlowType: AuthFlowType.pkce,
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRiaGRvYWNlcmF3bHlvenV3YmRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTk4ODg0MTksImV4cCI6MjAxNTQ2NDQxOX0.zRhol148YySEOTU6QUlLNvw7IcKK4udnN275_ZbexsU',
  );

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
          ref.watch(authListenerProvider);
          return const MyApp();
        },
      ),
    ),
  );
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
