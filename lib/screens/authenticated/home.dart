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
              Text(
                'What to check',
                style: AppTheme.getHeadingLarge(context),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              MenuItemCard(
                onTap: () => context.go(RoutePaths.contacts),
                icon: Icons.contacts,
                title: 'Your Contacts',
                subtitle: 'Check people, famely, friends and network',
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              Text(
                'Business & Organisation',
                style: AppTheme.getHeadingMedium(context),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              MenuItemCard(
                onTap: () => context.go(RoutePaths.demo),
                icon: Icons.email,
                title: 'Email / SMS',
                subtitle: 'Check an email og SMS you received',
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              MenuItemCard(
                onTap: () => context.go(RoutePaths.demo),
                icon: Icons.phone,
                title: 'Calls',
                subtitle: 'Check the person you are talking to on the phone',
              ),
              if (false) ...[
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
            ],
          ),
        ),
      ),
    );
  }
}
