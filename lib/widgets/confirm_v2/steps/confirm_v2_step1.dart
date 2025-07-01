import '../../../exports.dart';
import '../../../providers/contact_provider.dart';

class ConfirmV2Step1 extends ConsumerWidget {
  final String contactsId;
  final VoidCallback onStartConfirm;
  final String? errorMessage;

  const ConfirmV2Step1({
    super.key,
    required this.contactsId,
    required this.onStartConfirm,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactState = ref.watch(contactNotifierProvider);

    return contactState.when(
      data: (contact) => _buildContent(context, contact),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: CustomText(
          text: 'Fejl ved indlæsning af kontakt: $error',
          type: CustomTextType.bread,
          alignment: CustomTextAlignment.center,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Contact? contact) {
    if (contact == null) {
      return Center(
        child: CustomText(
          text: 'Kontakt ikke fundet',
          type: CustomTextType.bread,
          alignment: CustomTextAlignment.center,
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // CustomText(
        //   text: 'Bekræft kontakt',
        //   type: CustomTextType.head,
        //   alignment: CustomTextAlignment.center,
        // ),
        // Gap(AppDimensionsTheme.getLarge(context)),
        CustomButton(
          text: 'Ja, det er mig',
          onPressed: _handleConfirmPressed,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomText(
          text: 'Tryk på knappen for at bekræfte dig over for ${contact.firstName}',
          type: CustomTextType.bread,
          alignment: CustomTextAlignment.center,
        ),

        if (errorMessage != null) ...[
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomText(
            text: errorMessage!,
            type: CustomTextType.bread,
            alignment: CustomTextAlignment.center,
          ),
        ],
      ],
    );
  }

  void _handleConfirmPressed() {
    onStartConfirm();
  }
}

// Created on 2025-01-27 at 13:55:00
