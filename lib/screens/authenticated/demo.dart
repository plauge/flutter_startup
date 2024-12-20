import '../../exports.dart';

class DemoScreen extends AuthenticatedScreen {
  const DemoScreen({super.key});

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Demo',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
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
