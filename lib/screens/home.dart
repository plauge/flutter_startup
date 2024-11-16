import 'package:flutter/material.dart';
import '../exports.dart';
import '../exports_authenticated.dart';
import '../core/widgets/screens/authenticated_screen.dart';

class HomePage extends AuthenticatedScreen {
  const HomePage({super.key});

  @override
  Widget buildAuthenticatedWidget(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
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
              ref.read(authProvider.notifier).logout();
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
                      Gap(AppDimensionsTheme.getMedium(context)),
                      Text(
                        'Bruger: ${user?.email}',
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
