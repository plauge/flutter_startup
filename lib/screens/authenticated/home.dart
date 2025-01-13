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
      appBar: const AuthenticatedAppBar(showSettings: false),
      //drawer: const MainDrawer(),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CustomText(
                      text: 'Select Verification Type',
                      type: CustomTextType.head,
                      alignment: CustomTextAlignment.center,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomCard(
                      onPressed: () => context.go(RoutePaths.contacts),
                      icon: Icons.contacts,
                      headerText: 'Contacts',
                      bodyText: 'Validate people, family, friends and network',
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomCard(
                      onPressed: () => context.go(RoutePaths.demo),
                      icon: Icons.email,
                      headerText: 'Email & Text Messages',
                      bodyText: 'Validate an email or SMS/text message',
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomCard(
                      onPressed: () => context.go(RoutePaths.demo),
                      icon: Icons.phone,
                      headerText: 'Phone Calls',
                      bodyText: 'Check the ID of who you are talking with',
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomButton(
                      text: 'Create PIN Code',
                      onPressed: () => context.go(RoutePaths.info),
                      buttonType: CustomButtonType.primary,
                      icon: Icons.pin,
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
                          padding: EdgeInsets.all(
                              AppDimensionsTheme.getMedium(context)),
                        ),
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      StorageTestWidget(),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CustomButton(
                text: 'Settings',
                onPressed: () => context.go(RoutePaths.settings),
                buttonType: CustomButtonType.primary,
                icon: Icons.settings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
