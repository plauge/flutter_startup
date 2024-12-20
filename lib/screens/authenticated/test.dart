import '../../exports.dart';

class TestScreen extends AuthenticatedScreen {
  const TestScreen({super.key});

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Test'),
      body: Column(
        children: [
          AppTheme.getParentContainerStyle(context).applyToContainer(
            child: Text(
              'Welcome to Test Screen',
              style: AppTheme.getBodyMedium(context),
            ),
          ),
          Gap(AppDimensionsTheme.getLarge(context)),
          ElevatedButton(
            onPressed: () => context.go(RoutePaths.home),
            style: AppTheme.getPrimaryButtonStyle(context),
            child: Text(
              'Back to Home',
              style: AppTheme.getHeadingLarge(context),
            ),
          ),
        ],
      ),
    );
  }
}
