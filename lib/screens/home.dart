import '../exports.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Home', style: TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Log ud via AuthNotifier som håndterer logout
              ref.read(authProvider.notifier).logout();
              // Naviger til login siden
              context.go('/login');
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () {
                  context.go('/second');
                },
                child: Container(
                  color: AppColors.primaryColor(context),
                  child: Text(
                    'Home',
                    style: AppTheme.getBodyMedium(context),
                  ),
                  padding:
                      EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                ),
              ),
              Gap(AppDimensionsTheme.getMedium(context)),
              GestureDetector(
                onTap: () {
                  ref.read(counterProvider.notifier).increment();
                },
                child: Container(
                  color: AppColors.primaryColor(context),
                  child: Column(
                    children: [
                      Text(
                        'Klik på mig',
                        style: AppTheme.getBodyMedium(context),
                      ),
                      Text(
                        'Antal klik: $count',
                        style: AppTheme.getBodyMedium(context),
                      ),
                    ],
                  ),
                  padding:
                      EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
