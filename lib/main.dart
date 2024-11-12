import 'exports.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Brug AppTheme.lightTheme i stedet
      darkTheme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
