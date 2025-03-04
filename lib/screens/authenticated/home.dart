import '../../exports.dart';
import '../../providers/security_provider.dart';
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
                      text: 'Choose what to verify',
                      type: CustomTextType.head,
                      alignment: CustomTextAlignment.center,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomCard(
                      onPressed: () => context.go(RoutePaths.scanQr),
                      icon: Icons.qr_code_2,
                      headerText: 'Scan QR kode',
                      bodyText: 'Scan en QR kode med kameraet',
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomCard(
                      onPressed: () => context.go(RoutePaths.contacts),
                      icon: Icons.email,
                      headerText: 'Email & Text Messages',
                      bodyText: 'Validate an email or SMS/text message',
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomCard(
                      onPressed: () => context.go(RoutePaths.contacts),
                      icon: Icons.phone,
                      headerText: 'Phone Calls',
                      bodyText: 'Check the ID of who you are talking with',
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomCard(
                      onPressed: () => context.go(RoutePaths.contacts),
                      icon: Icons.contacts,
                      headerText: 'Contacts',
                      bodyText: 'Validate people, family, friends and network',
                    ),
                    if (false) ...[
                      CustomButton(
                        text: 'Create PIN Code',
                        onPressed: () => context.go(RoutePaths.onboardingBegin),
                        buttonType: CustomButtonType.primary,
                        icon: Icons.pin,
                      ),
                      CustomCard(
                        onPressed: () => context.go(RoutePaths.enterPincode),
                        icon: Icons.pin,
                        headerText: 'Enter PIN Code',
                        bodyText: 'Verify your identity with your PIN code',
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      FutureBuilder<List<dynamic>>(
                        future: ref
                            .read(securityVerificationProvider.notifier)
                            .doCaretaking('101'),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: [
                                CustomText(
                                  text: snapshot.data.toString(),
                                  type: CustomTextType.bread,
                                  alignment: CustomTextAlignment.left,
                                ),
                                Gap(AppDimensionsTheme.getLarge(context)),
                              ],
                            );
                          }
                          if (snapshot.hasError) {
                            return Column(
                              children: [
                                CustomText(
                                  text: 'Error: ${snapshot.error}',
                                  type: CustomTextType.bread,
                                  alignment: CustomTextAlignment.left,
                                ),
                                Gap(AppDimensionsTheme.getLarge(context)),
                              ],
                            );
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                      CustomButton(
                        text: 'Create PIN Code',
                        onPressed: () => context.go(RoutePaths.onboardingBegin),
                        buttonType: CustomButtonType.primary,
                        icon: Icons.pin,
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      StorageTestWidget(),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      const StorageTestToken(),
                      CustomButton(
                        text: 'Personal Information',
                        onPressed: () => context.go(RoutePaths.personalInfo),
                        buttonType: CustomButtonType.primary,
                        icon: Icons.person,
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      CustomButton(
                        text: 'Onboarding Complete',
                        onPressed: () =>
                            context.go(RoutePaths.onboardingComplete),
                        buttonType: CustomButtonType.primary,
                        icon: Icons.check_circle,
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      CustomButton(
                        text: 'Test Form',
                        onPressed: () => context.go(RoutePaths.testForm),
                        buttonType: CustomButtonType.primary,
                        icon: Icons.edit_document,
                      ),
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
                    Gap(AppDimensionsTheme.getLarge(context)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CustomButton(
                text: 'Settings',
                onPressed: () => context.go(RoutePaths.settings),
                buttonType: CustomButtonType.secondary,
                icon: Icons.settings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
