import '../../../exports.dart';

class WebCodeScreen extends AuthenticatedScreen {
  WebCodeScreen();

  static Future<WebCodeScreen> create() async {
    final screen = WebCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Web Code',
        backRoutePath: RoutePaths.home,
      ),
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
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomText(
                      text: 'Test a website',
                      type: CustomTextType.head,
                    ),
                    const Gap(16),
                    CustomText(
                      text: 'Dette er en test',
                      type: CustomTextType.bread,
                    ),
                    const Gap(24),
                    CustomButton(
                      onPressed: () {
                        // Functionality will be added later
                      },
                      text: 'Click to insert code',
                      buttonType: CustomButtonType.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Created: 2023-08-08 16:10:00
