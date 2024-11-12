import '../exports.dart';

class SecondPage extends ConsumerWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            //Navigator.pop(context);
            context.go('/home');
          },
        ),
        title: const Text('Second page', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: AppColors.primaryColor(context),
                child: Text(
                  'Dette er side 2',
                  style: AppTheme.getHeadingLarge(context),
                ),
                padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
              ),
              Gap(AppDimensionsTheme.getSmall(context)),
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
