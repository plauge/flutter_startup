import '../../exports.dart';

class DemoScreen extends AuthenticatedScreen {
  DemoScreen({super.key});

  // Static create method - den eneste måde at instantiere siden
  static Future<DemoScreen> create() async {
    final screen = DemoScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    // Watch userExtra from the provider
    final userExtraAsync = ref.watch(userExtraNotifierProvider);

    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Demo'),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTheme.getParentContainerStyle(context).applyToContainer(
              child: Text(
                'Welcome to Demo Screen',
                style: AppTheme.getBodyMedium(context),
              ),
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            AppTheme.getParentContainerStyle(context).applyToContainer(
              child: userExtraAsync.when(
                data: (userExtra) => userExtra == null
                    ? Text(
                        'No UserExtra data found',
                        style: AppTheme.getBodyMedium(context)
                            .copyWith(color: Colors.red),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UserExtra Data:',
                            style: AppTheme.getHeadingMedium(context),
                          ),
                          Gap(AppDimensionsTheme.getMedium(context)),
                          _buildUserExtraField(context, 'Created At',
                              userExtra.createdAt.toString()),
                          _buildUserExtraField(context, 'Status',
                              userExtra.status?.toString() ?? 'null'),
                          _buildUserExtraField(context, 'Latest Load',
                              userExtra.latestLoad?.toString() ?? 'null'),
                          _buildUserExtraField(context, 'Hash Pincode',
                              userExtra.hashPincode?.toString() ?? 'null'),
                          _buildUserExtraField(context, 'Email Confirmed',
                              userExtra.emailConfirmed?.toString() ?? 'null'),
                          _buildUserExtraField(context, 'Terms Confirmed',
                              userExtra.termsConfirmed?.toString() ?? 'null'),
                          _buildUserExtraField(
                              context, 'User ID', userExtra.userId ?? 'null'),
                          _buildUserExtraField(
                              context, 'User Extra ID', userExtra.userExtraId),
                          _buildUserExtraField(context, 'Salt Pincode',
                              userExtra.saltPincode?.toString() ?? 'null'),
                          _buildUserExtraField(context, 'Onboarding',
                              userExtra.onboarding.toString()),
                          _buildUserExtraField(
                              context,
                              'Encrypted Masterkey Check Value',
                              userExtra.encryptedMasterkeyCheckValue
                                      ?.toString() ??
                                  'null'),
                          _buildUserExtraField(
                              context, 'Email', userExtra.email ?? 'null'),
                          _buildUserExtraField(context, 'User Type',
                              userExtra.userType ?? 'null'),
                          _buildUserExtraField(context, 'Securekey Is Saved',
                              userExtra.securekeyIsSaved.toString()),
                        ],
                      ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text(
                  'Error: $error',
                  style: AppTheme.getBodyMedium(context)
                      .copyWith(color: Colors.red),
                ),
              ),
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            Center(
              child: CustomElevatedButton(
                onPressed: () => context.go(RoutePaths.home),
                text: 'Back to Home',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserExtraField(
      BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensionsTheme.getSmall(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: AppTheme.getBodyMedium(context)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.getBodyMedium(context),
            ),
          ),
        ],
      ),
    );
  }
}
