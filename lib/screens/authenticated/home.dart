import '../../exports.dart';

class HomePage extends AuthenticatedScreen {
  const HomePage({super.key});

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Home'),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
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
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.profile),
                style: AppTheme.getPrimaryButtonStyle(context),
                child: Text(
                  'Profile',
                  style: AppTheme.getHeadingLarge(context),
                ),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.contacts),
                style: AppTheme.getPrimaryButtonStyle(context),
                child: Text(
                  'Contacts',
                  style: AppTheme.getHeadingLarge(context),
                ),
              ),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.demo),
                style: AppTheme.getPrimaryButtonStyle(context),
                child: Text(
                  'Demo',
                  style: AppTheme.getHeadingLarge(context),
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
