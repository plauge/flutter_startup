import '../../../../exports.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfirmConnectionScreen extends AuthenticatedScreen {
  ConfirmConnectionScreen({super.key});

  static Future<ConfirmConnectionScreen> create() async {
    debugPrint('Creating ConfirmConnectionScreen');
    final screen = ConfirmConnectionScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _handleReject(BuildContext context) {
    debugPrint('🔄 Starting Level 3 connection rejection flow');
    final String? id = GoRouterState.of(context).queryParameters['invite'];
    debugPrint('📝 Level 3 invitation ID: ${id ?? 'null'}');
    if (id != null) {
      debugPrint(
          '✅ Valid Level 3 invitation ID found, proceeding with rejection');
      _performReject(context, id);
    } else {
      debugPrint('❌ No valid Level 3 invitation ID found, rejection cancelled');
    }
  }

  void _performReject(BuildContext context, String id) {
    debugPrint('Starting _performReject with ID: $id');

    // Send API kald i baggrunden
    debugPrint('Sending delete request for ID: $id');
    final ref = ProviderScope.containerOf(context);
    ref.read(deleteInvitationLevel3Provider(id));

    // Naviger til contacts siden med GoRouter
    debugPrint('Navigating to contacts with GoRouter');
    context.go(RoutePaths.contacts);
  }

  void _handleConfirm(BuildContext context) {
    debugPrint('🔄 Starting Level 3 connection confirmation flow');
    final String? id = GoRouterState.of(context).queryParameters['invite'];
    debugPrint('📝 Level 3 invitation ID: ${id ?? 'null'}');
    if (id != null) {
      debugPrint(
          '✅ Valid Level 3 invitation ID found, proceeding with confirmation');
      _performConfirm(context, id);
    } else {
      debugPrint(
          '❌ No valid Level 3 invitation ID found, confirmation cancelled');
    }
  }

  void _performConfirm(BuildContext context, String id) {
    debugPrint('Starting _performConfirm with ID: $id');

    // Send API kald i baggrunden
    debugPrint('Sending confirm request for ID: $id');
    final ref = ProviderScope.containerOf(context);
    ref.read(invitationLevel3ConfirmProvider(id));

    // Naviger til contacts siden med GoRouter
    debugPrint('Navigating to contacts with GoRouter');
    context.go(RoutePaths.contacts);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    debugPrint('1. Starting buildAuthenticatedWidget');
    final String? invite_id =
        GoRouterState.of(context).queryParameters['invite'];
    debugPrint('2. Got invite ID: $invite_id');

    if (invite_id == null) {
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
        child: ref.watch(readInvitationLevel3Provider(invite_id)).when(
              data: (data) {
                debugPrint(
                    '🎯 Received data in ConfirmConnectionScreen: $data');

                // Check if data is loaded
                if (data['loaded'] == false) {
                  return const Center(
                    child: CustomText(
                      text: 'Invitationen kunne ikke findes',
                      type: CustomTextType.bread,
                    ),
                  );
                }

                final String firstName = data['first_name'] ?? 'Ukendt';
                final String lastName = data['last_name'] ?? '';
                final String company = data['company'] ?? 'Ukendt virksomhed';
                final String? profileImage = data['profile_image'];
                final String tempName = data['temp_name'] ?? '';

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(
                              AppDimensionsTheme.getMedium(context)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CustomText(
                                text: 'Bekræft forbindelse',
                                type: CustomTextType.head,
                                alignment: CustomTextAlignment.center,
                              ),
                              const SizedBox(height: 16),
                              if (profileImage?.isNotEmpty == true)
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(profileImage!),
                                )
                              else
                                const CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      AssetImage('assets/images/profile.jpg'),
                                ),
                              const SizedBox(height: 16),
                              CustomText(
                                text: '$firstName $lastName',
                                type: CustomTextType.head,
                                alignment: CustomTextAlignment.center,
                              ),
                              CustomText(
                                text: company,
                                type: CustomTextType.cardHead,
                                alignment: CustomTextAlignment.center,
                              ),
                              const SizedBox(height: 16),
                              if (tempName.isNotEmpty) ...[
                                CustomText(
                                  text: 'Temp name: $tempName',
                                  type: CustomTextType.cardHead,
                                  alignment: CustomTextAlignment.center,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Afvis',
                              onPressed: () => _handleReject(context),
                              buttonType: CustomButtonType.secondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomButton(
                              text: 'Bekræft',
                              onPressed: () => _handleConfirm(context),
                              buttonType: CustomButtonType.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: CustomText(
                  text: 'Der skete en fejl: ${error.toString()}',
                  type: CustomTextType.bread,
                ),
              ),
            ),
      ),
    );
  }
}
