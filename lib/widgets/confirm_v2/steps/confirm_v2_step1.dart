import '../../../exports.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Bekræft kontakt',
          type: CustomTextType.head,
          alignment: CustomTextAlignment.center,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomText(
          text: 'Tryk på bekræft for at starte bekræftelsesprocessen',
          type: CustomTextType.bread,
          alignment: CustomTextAlignment.center,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomButton(
          text: 'Bekræft',
          onPressed: _handleConfirmPressed,
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
