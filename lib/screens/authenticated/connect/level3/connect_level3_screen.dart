import '../../../../exports.dart';

class ConnectLevel3Screen extends AuthenticatedScreen {
  ConnectLevel3Screen({super.key});

  static Future<ConnectLevel3Screen> create() async {
    final screen = ConnectLevel3Screen();
    return AuthenticatedScreen.create(screen);
  }

  void _handleCopyInvitationLink() {
    // TODO: Implement invitation link generation and copying
  }

  void _showOnlineConnectionInfo(BuildContext context) {
    // TODO: Implement online connection info modal
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
          title: 'Connect online', backRoutePath: RoutePaths.connect),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                text: 'Connect Online',
                type: CustomTextType.head,
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              Container(
                padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CustomText(
                      text: 'This connection will be ',
                      type: CustomTextType.bread,
                      alignment: CustomTextAlignment.left,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const CustomText(
                        text: 'Security Level 3',
                        type: CustomTextType.cardDescription,
                        alignment: CustomTextAlignment.left,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              const CustomText(
                text:
                    'Click the button below to generate and copy an invitation link.',
                type: CustomTextType.bread,
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              CustomButton(
                text: 'Copy Invitation Link',
                onPressed: _handleCopyInvitationLink,
                buttonType: CustomButtonType.primary,
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              CustomButton(
                text: 'Read About Online Connections',
                onPressed: () => _showOnlineConnectionInfo(context),
                icon: Icons.info_outline,
                buttonType: CustomButtonType.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
