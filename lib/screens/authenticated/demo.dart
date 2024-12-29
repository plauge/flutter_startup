import '../../exports.dart';

class DemoScreen extends AuthenticatedScreen {
  DemoScreen({super.key});

  // Static create method - den eneste måde at instantiere siden
  static Future<DemoScreen> create() async {
    final screen = DemoScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Demo'),
      body: Column(
        children: [
          AppTheme.getParentContainerStyle(context).applyToContainer(
            child: Text(
              'Welcome to Demo Screen',
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
