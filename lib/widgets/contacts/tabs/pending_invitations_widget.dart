import '../../../exports.dart';
import '../../../providers/invitation_pending_provider.dart';
import '../../../utils/image_url_validator.dart';

class PendingInvitationsWidget extends ConsumerWidget {
  static final log = scopedLogger(LogCategory.gui);
  const PendingInvitationsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(invitationPendingProvider).when(
          data: (invitations) {
            if (invitations is! List || invitations.isEmpty) {
              return Center(
                child: Text(
                  'No pending invitations found',
                  style: AppTheme.getBodyMedium(context),
                ),
              );
            }
            return Column(
              children: [
                //Gap(AppDimensionsTheme.getLarge(context)),
                // const Center(
                //   child: CustomText(
                //     text: 'Pending invitations',
                //     type: CustomTextType.bread,
                //   ),
                // ),
                // Gap(AppDimensionsTheme.getLarge(context)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: invitations.length,
                  itemBuilder: (context, index) {
                    final invitation = invitations[index];
                    final contactType = invitation['contact_type'];
                    final route = contactType == 1 ? RoutePaths.level1ConfirmConnection : RoutePaths.level3ConfirmConnection;

                    return Column(
                      children: [
                        CustomCardBatch(
                          icon: CardBatchIcon.contacts,
                          headerText: '${invitation['first_name']} ${invitation['last_name']}',
                          bodyText: invitation['company'],
                          onPressed: () => context.go('$route?invite=${invitation['contact_id']}'),
                          showArrow: true,
                          backgroundColor: CardBatchBackgroundColor.green,
                          image: ImageUrlValidator.isValidImageUrl(invitation['profile_image']?.toString())
                              ? NetworkImage(
                                  '${invitation['profile_image']}?v=${DateTime.now().millisecondsSinceEpoch}',
                                  headers: const {
                                    'Cache-Control': 'no-cache',
                                  },
                                )
                              : null,
                          level: invitation['contact_type'].toString(),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
                //Gap(AppDimensionsTheme.getLarge(context)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Error: $error',
              style: AppTheme.getBodyMedium(context),
            ),
          ),
        );
  }
}
