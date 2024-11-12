import 'exports.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          // Aktiver listener
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
    final router = ref.watch(routerProvider); // Brug routerProvider
    return MaterialApp.router(
      // Ændret til MaterialApp.router
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router, // Dette virker nu med MaterialApp.router
    );
  }
}
