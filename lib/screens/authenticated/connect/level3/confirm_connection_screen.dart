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

                // Extract additional data fields
                final DateTime createdAt =
                    DateTime.parse(data['created_at'] ?? '');
                final int receiverStatus = data['receiver_status'] ?? 1;
                final bool receiverAccepted =
                    data['receiver_accepted'] ?? false;
                final bool initiatorAccepted =
                    data['initiator_accepted'] ?? false;
                final String receiverEncryptedKey =
                    data['receiver_encrypted_key'] ?? '';
                final String initiatorEncryptedKey =
                    data['initiator_encrypted_key'] ?? '';
                final String initiatorUserId = data['initiator_user_id'] ?? '';
                final String? receiverUserId = data['receiver_user_id'];

                // Sikkerhedstjek for at undgå null-fejl
                final bool isInitiator = initiatorUserId == state.user.id;
                final bool isreceiver =
                    receiverUserId != null && receiverUserId == state.user.id;

                bool showRejectButton = true;
                bool showConfirmButton = false;

                final String text_no_confirmed_yet =
                    "I mangler begge at bekræfte før atforbinde.";
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
                              CustomText(
                                text: text_output,
                                type: CustomTextType.bread,
                                alignment: CustomTextAlignment.center,
                              ),
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
