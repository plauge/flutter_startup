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
                onTap: () => context.go(RoutePaths.contacts),
                child: Container(
                  padding:
                      EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                            AppDimensionsTheme.getMedium(context)),
                        decoration: BoxDecoration(
                          color:
                              AppColors.primaryColor(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.contacts,
                          size: 40,
                          color: AppColors.primaryColor(context),
                        ),
                      ),
                      Gap(AppDimensionsTheme.getMedium(context)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contacts',
                              style: AppTheme.getHeadingMedium(context),
                            ),
                            Gap(AppDimensionsTheme.getSmall(context)),
                            Text(
                              'Manage and view your contact list',
                              style: AppTheme.getBodyMedium(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
