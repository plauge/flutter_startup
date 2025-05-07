import '../../../exports.dart';
import '../../../providers/invitation_pending_provider.dart';

class PendingInvitationsWidget extends ConsumerWidget {
  const PendingInvitationsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(invitationPendingProvider).when(
          data: (invitations) {
            if (invitations is! List || invitations.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                Gap(AppDimensionsTheme.getLarge(context)),
                const Center(
                  child: CustomText(
                    text: 'Pending invitations',
                    type: CustomTextType.bread,
                  ),
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: invitations.length,
                  itemBuilder: (context, index) {
                    final invitation = invitations[index];
                    final contactType = invitation['contact_type'];
                    final route = contactType == 1
                        ? RoutePaths.confirmConnectionLevel1
                        : RoutePaths.confirmConnection;

                    return Column(
                      children: [
                        if (false) ...[
                          ContactListTile(
                            contact: Contact(
                              contactId: invitation['contact_id'],
                              firstName: invitation['first_name'],
                              lastName: invitation['last_name'],
                              company: invitation['company'] ?? '',
                              email: invitation['email'],
                              profileImage: invitation['profile_image'] ?? '',
                              isNew: invitation['is_new'] == 1,
                              star: invitation['star'] ?? false,
                              count: invitation['count'] ?? 0,
                              contactType: invitation['contact_type'],
                            ),
                            onTap: () {
                              print(
                                  'Tapped invitation. contact_type value: $contactType, type: ${contactType.runtimeType}');
                              print(
                                  'Navigating to route: $route with invite ID: ${invitation['contact_id']}');
                              context.go(
                                  '$route?invite=${invitation['contact_id']}');
                            },
                          ),
                        ],
                        CustomCard(
                          icon: CardIcon.contacts,
                          headerText:
                              '${invitation['first_name']} ${invitation['last_name']}',
                          bodyText: invitation['company'],
                          onPressed: () => context
                              .go('$route?invite=${invitation['contact_id']}'),
                          showArrow: true,
                          backgroundColor: CardBackgroundColor.green,
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
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
