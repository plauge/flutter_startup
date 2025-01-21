import '../../../../exports.dart';
import 'package:flutter/services.dart';

class ConnectLevel3Screen extends AuthenticatedScreen {
  ConnectLevel3Screen({super.key});
  late BuildContext _context;

  static Future<ConnectLevel3Screen> create() async {
    final screen = ConnectLevel3Screen();
    return AuthenticatedScreen.create(screen);
  }

  void _handleCopyInvitationLink() {
    const String invitationLink =
        'https://vegr.pixeldev.dk/connectionlink/index.php?par=';
    Clipboard.setData(const ClipboardData(text: invitationLink)).then((_) {
      ScaffoldMessenger.of(_context).showSnackBar(
        const SnackBar(
          content: Text('Invitationslink er kopieret til udklipsholderen'),
          duration: Duration(seconds: 2),
        ),
      );
    });
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
    _context = context;
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
