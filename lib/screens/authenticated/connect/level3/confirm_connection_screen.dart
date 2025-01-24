import '../../../../exports.dart';

class ConfirmConnectionScreen extends AuthenticatedScreen {
  ConfirmConnectionScreen({super.key});

  static Future<ConfirmConnectionScreen> create() async {
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
    final String? id = GoRouterState.of(context).queryParameters['invite'];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: const AuthenticatedAppBar(
        title: 'Confirm Connection',
        backRoutePath: RoutePaths.contacts,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Security Level 3',
                    style: AppTheme.getBodyMedium(context)
                        .copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                CustomText(
                  text: 'Invitation ID: $id',
                  type: CustomTextType.bread,
                  alignment: CustomTextAlignment.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      text: 'Reject',
                      onPressed: () => _handleReject(context),
                      buttonType: CustomButtonType.secondary,
                    ),
                    const SizedBox(width: 16),
                    CustomButton(
                      text: 'Confirm',
                      onPressed: () => _handleConfirm(context),
                      buttonType: CustomButtonType.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const CustomText(
                  text:
                      'By confirming this connection, you will establish a secure connection with this contact.',
                  type: CustomTextType.bread,
                  alignment: CustomTextAlignment.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
