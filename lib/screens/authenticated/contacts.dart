import '../../exports.dart';

class ContactsScreen extends AuthenticatedScreen {
  const ContactsScreen({super.key});

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Contacts'),
      body: Column(
        children: [
          AppTheme.getParentContainerStyle(context).applyToContainer(
            child: Text(
              'Text 1',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          AppTheme.getParentContainerStyle(context).applyToContainer(
            child: Text(
              'Text 2',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          AppTheme.getParentContainerStyle(context).applyToContainer(
            child: Text(
              'Text 3',
              style: Theme.of(context).textTheme.bodyMedium,
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
