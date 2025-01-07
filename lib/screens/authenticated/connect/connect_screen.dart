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
      appBar: const AuthenticatedAppBar(title: 'Connect'),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Connect with others',
                style: AppTheme.getHeadingLarge(context),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              MenuItemCard(
                onTap: () {},
                icon: Icons.qr_code,
                title: 'Share QR Code',
                subtitle: 'Let others scan your QR code to connect',
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              MenuItemCard(
                onTap: () {},
                icon: Icons.qr_code_scanner,
                title: 'Scan QR Code',
                subtitle: 'Scan someone else\'s QR code to connect',
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              MenuItemCard(
                onTap: () {},
                icon: Icons.share,
                title: 'Share Profile Link',
                subtitle: 'Share your profile link via message or email',
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              MenuItemCard(
                onTap: () {},
                icon: Icons.person_add,
                title: 'Enter Code',
                subtitle: 'Manually enter a connection code',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
