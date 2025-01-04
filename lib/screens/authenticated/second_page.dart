import '../../exports.dart';

class SecondPage extends AuthenticatedScreen {
  SecondPage({super.key});

  // Static create method - den eneste måde at instantiere siden
  static Future<SecondPage> create() async {
    final screen = SecondPage();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    final count = ref.watch(counterProvider);
    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Second page'),
      drawer: const MainDrawer(),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: AppColors.primaryColor(context),
                padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                child: Text(
                  'Dette er side 2',
                  style: AppTheme.getHeadingLarge(context),
                ),
              ),
              Gap(AppDimensionsTheme.getSmall(context)),
              CustomElevatedButton(
                onPressed: () => context.go(RoutePaths.home),
                text: 'Go 2 Home',
              ),
              Gap(AppDimensionsTheme.getSmall(context)),
              Container(
                color: AppColors.primaryColor(context),
                padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                child: Column(
                  children: [
                    Text(
                      'Antal klik: $count',
                      style: AppTheme.getBodyMedium(context),
                    ),
                    Gap(AppDimensionsTheme.getSmall(context)),
                    CustomElevatedButton(
                      onPressed: () =>
                          ref.read(counterProvider.notifier).increment(),
                      text: 'Klik på mig',
                    ),
                    if (auth.token != null)
                      UserProfileWidget(
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
            ],
          ),
        ),
      ),
    );
  }
}
