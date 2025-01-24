import '../../../../exports.dart';

class ConfirmConnectionScreen extends AuthenticatedScreen {
  ConfirmConnectionScreen({super.key});

  static Future<ConfirmConnectionScreen> create() async {
    debugPrint('Creating ConfirmConnectionScreen');
    final screen = ConfirmConnectionScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _handleReject(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText(
          text: 'Afvis forbindelse',
          type: CustomTextType.head,
        ),
        content: const CustomText(
          text: 'Er du sikker på at du vil afvise denne forbindelse?',
          type: CustomTextType.bread,
        ),
        actions: [
          CustomButton(
            text: 'Nej',
            onPressed: () => Navigator.pop(context),
            buttonType: CustomButtonType.secondary,
          ),
          CustomButton(
            text: 'Ja, afvis',
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement reject logic with InvitationLevel3Service
            },
            buttonType: CustomButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _handleConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText(
          text: 'Bekræft forbindelse',
          type: CustomTextType.head,
        ),
        content: const CustomText(
          text: 'Er du sikker på at du vil acceptere denne forbindelse?',
          type: CustomTextType.bread,
        ),
        actions: [
          CustomButton(
            text: 'Nej',
            onPressed: () => Navigator.pop(context),
            buttonType: CustomButtonType.secondary,
          ),
          CustomButton(
            text: 'Ja, accepter',
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement accept logic with InvitationLevel3Service
            },
            buttonType: CustomButtonType.primary,
          ),
        ],
      ),
    );
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    debugPrint('1. Starting buildAuthenticatedWidget');
    final String? id = GoRouterState.of(context).queryParameters['invite'];
    debugPrint('2. Got invite ID: $id');

    if (id == null) {
      return const Scaffold(
        body: Center(
          child: CustomText(
            text: 'Ingen invitation ID fundet',
            type: CustomTextType.bread,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: const AuthenticatedAppBar(
        title: 'Bekræft Forbindelse',
        backRoutePath: RoutePaths.contacts,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                    const SizedBox(height: 16),
                    const CustomText(
                      text: 'John Doe',
                      type: CustomTextType.head,
                      alignment: CustomTextAlignment.center,
                    ),
                    const CustomText(
                      text: 'ACME Corporation',
                      type: CustomTextType.cardHead,
                      alignment: CustomTextAlignment.center,
                    ),
                    const SizedBox(height: 16),
                    CustomText(
                      text: 'Invitation ID: $id',
                      type: CustomTextType.bread,
                      alignment: CustomTextAlignment.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: constraints.maxWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Reject',
                              onPressed: () => _handleReject(context),
                              buttonType: CustomButtonType.secondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomButton(
                              text: 'Confirm',
                              onPressed: () => _handleConfirm(context),
                              buttonType: CustomButtonType.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
