import '../../exports.dart';

class TestScreen extends AuthenticatedScreen {
  TestScreen({super.key});

  // Static create method - den eneste måde at instantiere siden
  static Future<TestScreen> create() async {
    final screen = TestScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Test'),
      drawer: const MainDrawer(),
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
