import '../../../../exports.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfirmConnectionLevel1Screen extends AuthenticatedScreen {
  ConfirmConnectionLevel1Screen({super.key});

  static Future<ConfirmConnectionLevel1Screen> create() async {
    debugPrint('Creating ConfirmConnectionLevel1Screen');
    final screen = ConfirmConnectionLevel1Screen();
    return AuthenticatedScreen.create(screen);
  }

  void _handleReject(BuildContext context) {
    // Hent ID før vi åbner dialog
    final String? id = GoRouterState.of(context).queryParameters['invite'];
    debugPrint('Invitation ID in _handleReject: $id');

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
              if (id != null) {
                _performReject(context, id);
              }
            },
            buttonType: CustomButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _performReject(BuildContext context, String id) {
    debugPrint('Starting _performReject with ID: $id');

    // Send API kald i baggrunden
    debugPrint('Sending delete request for ID: $id');
    final ref = ProviderScope.containerOf(context);
    ref.read(deleteInvitationLevel1Provider(id));

    // Naviger til contacts siden med GoRouter
    debugPrint('Navigating to contacts with GoRouter');
    context.go(RoutePaths.contacts);
  }

  void _handleConfirm(BuildContext context) {
    // Hent ID før vi åbner dialog
    final String? id = GoRouterState.of(context).queryParameters['invite'];
    debugPrint('Invitation ID in _handleConfirm: $id');

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
              if (id != null) {
                _performConfirm(context, id);
              }
            },
            buttonType: CustomButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _performConfirm(BuildContext context, String id) {
    debugPrint('Starting _performConfirm with ID: $id');

    // Send API kald i baggrunden
    debugPrint('Sending confirm request for ID: $id');
    final ref = ProviderScope.containerOf(context);
    ref.read(invitationLevel1ConfirmProvider(id));

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
        title: 'Bekræft Level 1 Forbindelse',
        backRoutePath: RoutePaths.contacts,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: ref.watch(readInvitationLevel1Provider(id)).when(
              data: (data) {
                debugPrint(
                    '🎯 Received data in ConfirmConnectionLevel1Screen for ID: $id');
                debugPrint('🎯 Raw response data: $data');

                // Check if data is loaded
                final payload = data['payload'] as Map<String, dynamic>;
                if (payload['loaded'] == false) {
                  debugPrint('❌ Data not loaded for ID: $id');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomText(
                          text: 'Du har ikke adgang til at se denne invitation',
                          type: CustomTextType.head,
                          alignment: CustomTextAlignment.center,
                        ),
                        const Gap(16),
                        const CustomText(
                          text:
                              'Kun den bruger som har oprettet invitationen kan se detaljerne.',
                          type: CustomTextType.bread,
                          alignment: CustomTextAlignment.center,
                        ),
                        const Gap(32),
                        CustomButton(
                          text: 'Tilbage',
                          onPressed: () => context.go(RoutePaths.contacts),
                          buttonType: CustomButtonType.secondary,
                        ),
                      ],
                    ),
                  );
                }

                final String firstName = payload['first_name'] ?? 'Ukendt';
                final String lastName = payload['last_name'] ?? '';
                final String company =
                    payload['company'] ?? 'Ukendt virksomhed';
                final String? profileImage = payload['profile_image'];
                final String tempName = payload['temp_name'] ?? '';

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
                                text: 'Bekræft Level 1 forbindelse',
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
