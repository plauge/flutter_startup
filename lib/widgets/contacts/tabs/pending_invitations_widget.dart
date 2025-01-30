import '../../../exports.dart';

class PendingInvitationsWidget extends ConsumerWidget {
  const PendingInvitationsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(invitationLevel3WaitingForInitiatorProvider).when(
          data: (invitations) {
            if (invitations is! List || invitations.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                Gap(AppDimensionsTheme.getLarge(context)),
                const Center(
                  child: CustomText(
                    text: 'Dine invitationer',
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
                    return ContactListTile(
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
                        context.go(
                            '${RoutePaths.confirmConnection}?invite=${invitation['contact_id']}');
                      },
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
