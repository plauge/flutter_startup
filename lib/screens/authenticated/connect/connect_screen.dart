import '../../../exports.dart';

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
      appBar: const AuthenticatedAppBar(
        title: 'Connect',
        backRoutePath: '/contacts',
        showSettings: false,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Security Level',
                style: AppTheme.getHeadingLarge(context),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              MenuItemCard(
                onTap: () {},
                icon: Icons.qr_code,
                title: 'Meet in Person (most secure)',
                subtitle:
                    'When meeting your new contact in person, and they can present their phone to you for verification or interaction.',
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              MenuItemCard(
                onTap: () {},
                icon: Icons.qr_code_scanner,
                title: 'Connect online (less secure)',
                subtitle:
                    'If meeting in person isn’t possible, use email, text, or other remote methods to establish contact.',
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              Text(
                'Connections are assigned different security levels based on how they are created, each with varying degrees of trust and authenticity.',
                style: AppTheme.getHeadingMedium(context),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              ElevatedButton(
                onPressed: () => _showSecurityLevelsModal(context),
                style: AppTheme.getPrimaryButtonStyle(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Read About Security Levels'),
                  ],
                ),
              ),
            ],
          ),
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
                    Text(
                      'Security Levels',
                      style: AppTheme.getHeadingLarge(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                Text(
                  'Connections can be created through different methods. Based on the method and context, your contact is assigned a security level as described below:',
                  style: AppTheme.getBodyMedium(context),
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
                    children: [
                      Text(
                        'Security Level 1',
                        style: AppTheme.getHeadingMedium(context),
                      ),
                      Gap(AppDimensionsTheme.getMedium(context)),
                      Text(
                        'Level 1 requires you and your contact to meet in person, ensuring the highest level of security by directly verifying their identity.',
                        style: AppTheme.getBodyMedium(context),
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
                    children: [
                      Text(
                        'Security Level 2',
                        style: AppTheme.getHeadingMedium(context),
                      ),
                      Gap(AppDimensionsTheme.getMedium(context)),
                      Text(
                        'Level 2 is currently under development and is not yet available.',
                        style: AppTheme.getBodyMedium(context),
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
                    children: [
                      Text(
                        'Security Level 3',
                        style: AppTheme.getHeadingMedium(context),
                      ),
                      Gap(AppDimensionsTheme.getMedium(context)),
                      Text(
                        'Level 3 connections can be created via email, text messages, or similar forms of communication. However, it is inherently less secure as there is no way to fully verify the identity of the person you are communicating with.',
                        style: AppTheme.getBodyMedium(context),
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
