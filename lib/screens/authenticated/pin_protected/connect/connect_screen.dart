import '../../../../exports.dart';
import '../../../../services/i18n_service.dart';

class ConnectScreen extends AuthenticatedScreen {
  ConnectScreen({super.key});

  static Future<ConnectScreen> create() async {
    final screen = ConnectScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_contacts_connect.connect_header', fallback: 'Connect'),
        // backRoutePath: '/contacts',
        backRoutePath: RoutePaths.home,
        showSettings: false,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomText(
                      text: I18nService().t('screen_contacts_connect.connect_how_to_connect', fallback: 'How do you want to connect?'),
                      type: CustomTextType.head,
                      alignment: CustomTextAlignment.center,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomCardBatch(
                      icon: CardBatchIcon.meetInPerson,
                      headerText: I18nService().t('screen_contacts_connect.connect_meet_in_person', fallback: 'Meet in Person (most secure)'),
                      bodyText: I18nService().t('screen_contacts_connect.connect_meet_in_person_body', fallback: 'When meeting your new contact in person, and they can present their phone to you for verification or interaction.'),
                      onPressed: () => context.go(RoutePaths.level1CreateOrScanQr),
                      showArrow: true,
                      level: '1',
                      backgroundColor: CardBatchBackgroundColor.lightGreen,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomCardBatch(
                      icon: CardBatchIcon.connectOnline,
                      headerText: I18nService().t('screen_contacts_connect.connect_connect_online', fallback: 'Connect online (less secure)'),
                      bodyText: I18nService().t('screen_contacts_connect.connect_connect_online_body', fallback: "If meeting in person isn't possible, use email, text, or other remote methods to establish contact."),
                      onPressed: () => context.go(RoutePaths.level3LinkGenerator),
                      showArrow: true,
                      level: '3',
                      backgroundColor: CardBatchBackgroundColor.lightOrange,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    // const CustomText(
                    //   text:
                    //       'Connections are assigned different security levels based on how they are created, each with varying degrees of trust and authenticity.',
                    //   type: CustomTextType.bread,
                    // ),
                  ],
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 20),
            //   child: CustomButton(
            //     text: I18nService().t('screen_contacts_connect.connect_read_about_security_levels', fallback: 'Read About Security Levels'),
            //     onPressed: () => _showSecurityLevelsModal(context),
            //     icon: Icons.info_outline,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _showSecurityLevelsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomText(
                      text: 'Security Levels',
                      type: CustomTextType.head,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                const CustomText(
                  text: 'Connections can be created through different methods. Based on the method and context, your contact is assigned a security level as described below:',
                  type: CustomTextType.bread,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      CustomText(
                        text: 'Security Level 1',
                        type: CustomTextType.cardHead,
                      ),
                      Gap(8),
                      CustomText(
                        text: 'Level 1 requires you and your contact to meet in person, ensuring the highest level of security by directly verifying their identity.',
                        type: CustomTextType.cardDescription,
                      ),
                    ],
                  ),
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      CustomText(
                        text: 'Security Level 2',
                        type: CustomTextType.cardHead,
                      ),
                      Gap(8),
                      CustomText(
                        text: 'Level 2 is currently under development and is not yet available.',
                        type: CustomTextType.cardDescription,
                      ),
                    ],
                  ),
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      CustomText(
                        text: 'Security Level 3',
                        type: CustomTextType.cardHead,
                      ),
                      Gap(8),
                      CustomText(
                        text:
                            'Level 3 connections can be created via email, text messages, or similar forms of communication. However, it is inherently less secure as there is no way to fully verify the identity of the person you are communicating with.',
                        type: CustomTextType.cardDescription,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
