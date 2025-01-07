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
                onPressed: () {},
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
}
