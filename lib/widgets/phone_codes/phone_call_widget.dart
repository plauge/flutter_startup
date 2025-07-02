import '../../exports.dart';

class PhoneCallWidget extends ConsumerStatefulWidget {
  final String initiatorName;
  final String? initiatorCompany;
  final String confirmCode;
  final DateTime createdAt;
  final String? initiatorPhone;
  final String? initiatorEmail;
  final String? initiatorAddress;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;

  const PhoneCallWidget({
    super.key,
    required this.initiatorName,
    this.initiatorCompany,
    required this.confirmCode,
    required this.createdAt,
    this.initiatorPhone,
    this.initiatorEmail,
    this.initiatorAddress,
    this.onConfirm,
    this.onReject,
  });

  @override
  ConsumerState<PhoneCallWidget> createState() => _PhoneCallWidgetState();
}

class _PhoneCallWidgetState extends ConsumerState<PhoneCallWidget> {
  static final log = scopedLogger(LogCategory.gui);

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(widget.createdAt);

    if (difference.inMinutes < 1) {
      return I18nService().t('phone_call.created_seconds_ago', fallback: 'Oprettet for ${difference.inSeconds} sekunder siden', variables: {'seconds': difference.inSeconds.toString()});
    } else if (difference.inHours < 1) {
      return I18nService().t('phone_call.created_minutes_ago', fallback: 'Oprettet for ${difference.inMinutes} minutter siden', variables: {'minutes': difference.inMinutes.toString()});
    } else {
      return I18nService().t('phone_call.created_hours_ago', fallback: 'Oprettet for ${difference.inHours} timer siden', variables: {'hours': difference.inHours.toString()});
    }
  }

  List<Widget> _buildCodeDigits() {
    final digits = widget.confirmCode.split('');
    return digits
        .map((digit) => Container(
              width: 60,
              height: 60,
              margin: EdgeInsets.symmetric(horizontal: AppDimensionsTheme.getSmall(context)),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: CustomText(
                  text: digit,
                  type: CustomTextType.helper,
                ),
              ),
            ))
        .toList();
  }

  void _handleConfirm() {
    log('PhoneCallWidget._handleConfirm - Bekræfter telefon kode');
    widget.onConfirm?.call();
  }

  void _handleReject() {
    log('PhoneCallWidget._handleReject - Afviser telefon kode');
    widget.onReject?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme.getParentContainerStyle(context).applyToContainer(
      child: Column(
        children: [
          // Header with timer
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
            decoration: BoxDecoration(
              color: AppColors.primaryColor(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 20,
                ),
                Gap(AppDimensionsTheme.getSmall(context)),
                CustomText(
                  text: _getTimeAgo(),
                  type: CustomTextType.bread,
                ),
              ],
            ),
          ),

          // Main content
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppDimensionsTheme.getLarge(context)),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                // ID-TRUSTER logo/badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensionsTheme.getMedium(context),
                    vertical: AppDimensionsTheme.getSmall(context),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor(context),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const CustomText(
                    text: 'ID-TRUSTER',
                    type: CustomTextType.bread,
                  ),
                ),

                Gap(AppDimensionsTheme.getMedium(context)),

                // Name
                CustomText(
                  text: widget.initiatorName,
                  type: CustomTextType.head,
                ),

                // Company (if provided)
                if (widget.initiatorCompany != null) ...[
                  Gap(AppDimensionsTheme.getSmall(context)),
                  CustomText(
                    text: widget.initiatorCompany!,
                    type: CustomTextType.bread,
                  ),
                ],

                Gap(AppDimensionsTheme.getLarge(context)),

                // Instruction text
                CustomText(
                  text: I18nService().t('phone_call.get_person_to_say_code', fallback: 'Få ${widget.initiatorName} til at sige denne kode:', variables: {'name': widget.initiatorName}),
                  type: CustomTextType.bread,
                ),

                Gap(AppDimensionsTheme.getMedium(context)),

                // Code display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildCodeDigits(),
                ),

                Gap(AppDimensionsTheme.getLarge(context)),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: I18nService().t('phone_call.reject', fallback: 'Afvis'),
                        onPressed: _handleReject,
                        buttonType: CustomButtonType.secondary,
                      ),
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    Expanded(
                      child: CustomButton(
                        text: I18nService().t('phone_call.confirm', fallback: 'Bekræft'),
                        onPressed: _handleConfirm,
                        buttonType: CustomButtonType.primary,
                      ),
                    ),
                  ],
                ),

                Gap(AppDimensionsTheme.getLarge(context)),

                // Contact information
                if (widget.initiatorAddress != null || widget.initiatorPhone != null || widget.initiatorEmail != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.initiatorAddress != null) ...[
                          CustomText(
                            text: widget.initiatorAddress!,
                            type: CustomTextType.small_bread,
                          ),
                          Gap(AppDimensionsTheme.getSmall(context)),
                        ],
                        if (widget.initiatorPhone != null) ...[
                          CustomText(
                            text: I18nService().t('phone_call.phone', fallback: 'Telefon: ${widget.initiatorPhone}', variables: {'phone': widget.initiatorPhone!}),
                            type: CustomTextType.small_bread,
                          ),
                          Gap(AppDimensionsTheme.getSmall(context)),
                        ],
                        if (widget.initiatorEmail != null) ...[
                          CustomText(
                            text: I18nService().t('phone_call.email', fallback: 'E-mail: ${widget.initiatorEmail}', variables: {'email': widget.initiatorEmail!}),
                            type: CustomTextType.small_bread,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                Gap(AppDimensionsTheme.getMedium(context)),

                // Last controlled date
                CustomText(
                  text: I18nService().t('phone_call.last_controlled', fallback: 'Sidst kontrolleret: ${widget.createdAt.day.toString().padLeft(2, '0')}.${widget.createdAt.month.toString().padLeft(2, '0')}.${widget.createdAt.year}'),
                  type: CustomTextType.small_bread,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Created: 2025-01-26 17:30:00
