import '../../exports.dart';
//import 'package:flutter/material.dart';

class HomePage extends AuthenticatedScreen {
  // Protected constructor
  HomePage({super.key});

  // Static create method - den eneste måde at instantiere siden
  static Future<HomePage> create() async {
    final page = HomePage();
    return AuthenticatedScreen.create(page);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Home'),
      drawer: const MainDrawer(),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                        'Bruger: ${auth.user.email}',
                        style: AppTheme.getBodyMedium(context),
                      ),
                      const FaceIdButton(),
                    ],
                  ),
                  padding:
                      EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                ),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              StorageTestWidget(),
              ContactsAllWidget(
                user: AppUser(
                  id: auth.user.id,
                  email: auth.user.email!,
                  createdAt: auth.user.createdAt,
                  lastLoginAt: DateTime.now(),
                ),
                authToken: auth.token!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
