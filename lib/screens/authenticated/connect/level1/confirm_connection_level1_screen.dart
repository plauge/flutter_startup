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
    debugPrint('🔄 Starting _handleReject');
    final String? id = GoRouterState.of(context).queryParameters['invite'];
    debugPrint('📝 Invitation ID in _handleReject: ${id ?? 'null'}');
    if (id != null) {
      debugPrint('✅ Valid ID found, proceeding with rejection');
      _performReject(context, id);
    } else {
      debugPrint('❌ No valid ID found, rejection cancelled');
    }
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
    final String? id = GoRouterState.of(context).queryParameters['invite'];
    debugPrint('Invitation ID in _handleConfirm: $id');
    if (id != null) {
      _performConfirm(context, id);
      debugPrint('Invitation ID found in _handleConfirm');
    } else {
      debugPrint('No invitation ID found in _handleConfirm');
      CustomSnackBar.show(
        context: context,
        text: 'Ingen invitation ID fundet',
        type: CustomTextType.button,
        backgroundColor: Colors.red,
      );
    }
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

                // Extract additional data fields
                final DateTime createdAt = payload['created_at'] != null &&
                        payload['created_at'].toString().isNotEmpty
                    ? DateTime.parse(payload['created_at'].toString())
                    : DateTime.now();
                final int receiverStatus = payload['receiver_status'] ?? 1;
                final bool receiverAccepted =
                    payload['receiver_accepted'] ?? false;
                final bool initiatorAccepted =
                    payload['initiator_accepted'] ?? false;
                final String receiverEncryptedKey =
                    payload['receiver_encrypted_key'] ?? '';
                final String initiatorEncryptedKey =
                    payload['initiator_encrypted_key'] ?? '';
                final String initiatorUserId =
                    payload['initiator_user_id'] ?? '';
                final String? receiverUserId = payload['receiver_user_id'];

                // Sikkerhedstjek for at undgå null-fejl
                final bool isInitiator = initiatorUserId == state.user.id;
                final bool isreceiver =
                    receiverUserId != null && receiverUserId == state.user.id;

                bool showRejectButton = true;
                bool showConfirmButton = false;

                final String text_no_confirmed_yet =
                    "I mangler begge at bekræfte før at forbinde.";
                final String text_missing_your_confirm =
                    "Kun du mangler bekræfte for at forbinde.";
                final String text_missing_connection_confirm =
                    "Din kontakt har ikke bekræftet endnu";

                String text_output = text_no_confirmed_yet;

                if (isInitiator && !initiatorAccepted) {
                  showConfirmButton = true;
                }

                if (isInitiator && !receiverAccepted && !initiatorAccepted) {
                  text_output = text_no_confirmed_yet;
                }

                if (isInitiator && receiverAccepted && !initiatorAccepted) {
                  text_output = text_missing_your_confirm;
                }

                if (isInitiator && !receiverAccepted && initiatorAccepted) {
                  text_output = text_missing_connection_confirm;
                }

                if (!isInitiator && !receiverAccepted) {
                  showConfirmButton = true;
                }

                if (!isInitiator && !receiverAccepted && !initiatorAccepted) {
                  text_output = text_no_confirmed_yet;
                }

                if (!isInitiator && !receiverAccepted && initiatorAccepted) {
                  text_output = text_missing_your_confirm;
                }

                if (!isInitiator && receiverAccepted && !initiatorAccepted) {
                  text_output = text_missing_connection_confirm;
                }

                // Bemærk: Der er logiske fejl i betingelserne ovenfor, da !receiverAccepted og receiverAccepted ikke kan være sande samtidigt

                debugPrint('🎯 Connection details:');
                debugPrint('First name: $firstName');
                debugPrint('Last name: $lastName');
                debugPrint('Company: $company');
                debugPrint('Profile image: $profileImage');
                debugPrint('Created at: $createdAt');
                debugPrint('receiver status: $receiverStatus');
                debugPrint('receiver accepted: $receiverAccepted');
                debugPrint('Initiator accepted: $initiatorAccepted');
                debugPrint('Is initiator: $isInitiator');
                debugPrint('Is receiver: $isreceiver');
                debugPrint('Show reject button: $showRejectButton');
                debugPrint('Show confirm button: $showConfirmButton');
                debugPrint(
                    'receiver encrypted key length: ${receiverEncryptedKey.length}');
                debugPrint(
                    'Initiator encrypted key length: ${initiatorEncryptedKey.length}');

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
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
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
                              CustomText(
                                text: text_output,
                                type: CustomTextType.bread,
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
                          if (showRejectButton) ...[
                            Expanded(
                              child: CustomButton(
                                text: 'Afvis',
                                onPressed: () => _handleReject(context),
                                buttonType: CustomButtonType.secondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          if (showConfirmButton)
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
