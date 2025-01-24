import '../../../../exports.dart';

class ConfirmConnectionScreen extends AuthenticatedScreen {
  ConfirmConnectionScreen({super.key});

  static Future<ConfirmConnectionScreen> create() async {
    final screen = ConfirmConnectionScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    final String? id = GoRouterState.of(context).queryParameters['invite'];

    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Confirm Connection',
        backRoutePath: RoutePaths.contacts,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Center(
          child: CustomText(
            text: 'Invitation ID: $id',
            type: CustomTextType.bread,
          ),
        ),
      ),
    );
  }
}
