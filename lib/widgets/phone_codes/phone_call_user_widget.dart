import 'package:flutter_svg/flutter_svg.dart';
import '../../exports.dart';
import 'phone_call_base_widget.dart';

enum ViewType { Phone, Text }

class PhoneCallUserWidget extends ConsumerStatefulWidget {
  final String initiatorName;
  final String? initiatorCompany;
  final DateTime createdAt;
  final String? initiatorPhone;
  final String? initiatorEmail;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final bool history;
  final int action;
  final String? phoneCodesId;
  final ViewType viewType;
  final String? customerUserId;
  final String? profileImage;

  const PhoneCallUserWidget({
    super.key,
    required this.initiatorName,
    this.initiatorCompany,
    required this.createdAt,
    this.initiatorPhone,
    this.initiatorEmail,
    this.onConfirm,
    this.onReject,
    this.history = false,
    this.action = 0,
    this.phoneCodesId,
    required this.viewType,
    this.customerUserId,
    this.profileImage,
  });

  @override
  ConsumerState<PhoneCallUserWidget> createState() => _PhoneCallUserWidgetState();
}

class _PhoneCallUserWidgetState extends PhoneCallBaseState<PhoneCallUserWidget> {
  // Implement abstract properties from base class
  @override
  String get initiatorName => widget.initiatorName;
  @override
  String? get initiatorCompany => widget.initiatorCompany;
  @override
  @deprecated
  String get confirmCode => ''; // Deprecated - not used in this widget
  @override
  DateTime get createdAt => widget.createdAt;
  @override
  @deprecated
  DateTime get lastControlDateAt => DateTime.now(); // Deprecated - not used in this widget
  @override
  String? get initiatorPhone => widget.initiatorPhone;
  String? get initiatorEmail => widget.initiatorEmail;
  String? get customerUserId => widget.customerUserId;
  @override
  @deprecated
  String? get websiteUrl => null; // Deprecated - not used in this widget
  @override
  @deprecated
  Map<String, dynamic>? get initiatorAddress => null; // Deprecated - not used in this widget
  @override
  VoidCallback? get onConfirm => widget.onConfirm;
  @override
  VoidCallback? get onReject => widget.onReject;
  @override
  bool get history => widget.history;
  @override
  int get action => widget.action;
  @override
  String? get phoneCodesId => widget.phoneCodesId;
  @override
  @deprecated
  String? get logoPath => null; // Deprecated - not used in this widget
  @override
  @deprecated
  bool get demo => false; // Deprecated - not used in this widget
  @override
  ViewType get viewType => widget.viewType;

  @override
  String getWidgetTypeName() => 'phone_call_user_widget';

  Future<void> _handleConfirmWithDecryption(WidgetRef ref, String encryptedPhoneNumber, BuildContext context) async {
    try {
      // Vis modal først
      PhoneCallConfirmationModal.show(context);

      // Hent brugerens token
      final token = await ref.read(storageProvider.notifier).getCurrentUserToken();

      if (token == null) {
        log('${getWidgetTypeName()}._handleConfirmWithDecryption - Fejl: Kunne ikke hente token');
        return;
      }

      // Dekrypter telefonnummeret
      final decryptedPhoneNumber = await AESGCMEncryptionUtils.decryptString(encryptedPhoneNumber, token);

      log('${getWidgetTypeName()}._handleConfirmWithDecryption - Telefonnummer dekrypteret succesfuldt');

      // Hent den krypterede fælles nøgle for kontakten
      if (customerUserId == null) {
        log('${getWidgetTypeName()}._handleConfirmWithDecryption - Fejl: customerUserId er null');
        return;
      }

      final contactEncryptedKeyAsync = await ref.read(contactGetMyEncryptedKeyProvider(customerUserId!).future);

      if (contactEncryptedKeyAsync == null) {
        log('${getWidgetTypeName()}._handleConfirmWithDecryption - Fejl: Kunne ikke hente krypteret fælles nøgle');
        return;
      }

      log('${getWidgetTypeName()}._handleConfirmWithDecryption - Krypteret fælles nøgle hentet succesfuldt');

      // Dekrypter den fælles nøgle med token
      final commonKey = await AESGCMEncryptionUtils.decryptString(contactEncryptedKeyAsync, token);

      log('${getWidgetTypeName()}._handleConfirmWithDecryption - Fælles nøgle dekrypteret succesfuldt');

      // Krypter telefonnummeret med den fælles nøgle
      final encryptedPhoneNumberWithCommonKey = await AESGCMEncryptionUtils.encryptString(decryptedPhoneNumber, commonKey);

      log('${getWidgetTypeName()}._handleConfirmWithDecryption - Telefonnummer krypteret med fælles nøgle succesfuldt');

      // Send det krypterede telefonnummer videre til handleConfirm
      handleConfirm(ref, inputEncryptedPhoneNumber: encryptedPhoneNumberWithCommonKey);
    } catch (e) {
      log('${getWidgetTypeName()}._handleConfirmWithDecryption - Fejl ved dekryptering: $e');
      // Håndter fejl - måske vis en fejlbesked til brugeren
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: AppDimensionsTheme.getMedium(context),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF418BA2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/phone/phone_clock.svg',
                      width: 16,
                      height: 16,
                    ),
                    Gap(AppDimensionsTheme.getSmall(context)),
                    widget.history
                        ? Text(
                            '${createdAtLocal.day.toString().padLeft(2, '0')}.${createdAtLocal.month.toString().padLeft(2, '0')}.${createdAtLocal.year} ${createdAtLocal.hour.toString().padLeft(2, '0')}:${createdAtLocal.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 22 / 12, // 22px line-height / 12px font-size = 1.833
                            ),
                          )
                        : ValueListenableBuilder<String>(
                            valueListenable: timeAgoNotifier,
                            builder: (context, timeAgo, child) {
                              return Text(
                                timeAgo,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 22 / 12, // 22px line-height / 12px font-size = 1.833
                                ),
                              );
                            },
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
                    // Profile image
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 7,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 90,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: (widget.profileImage != null && widget.profileImage!.isNotEmpty) ? NetworkImage(widget.profileImage!) : null,
                            child: (widget.profileImage == null || widget.profileImage!.isEmpty) ? const Icon(Icons.person, size: 50) : null,
                          ),
                        ),
                      ],
                    ),

                    Gap(AppDimensionsTheme.getLarge(context)),

                    // Name
                    Text(
                      widget.initiatorName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF014459),
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    Gap(AppDimensionsTheme.getLarge(context)),

// Herfra - kun vis ved Phone viewType
                    if (widget.viewType == ViewType.Phone && 1 == 1)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
// Action buttons or confirmed status
                            widget.history
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        getActionIcon(),
                                        width: 30,
                                        height: 30,
                                        colorFilter: ColorFilter.mode(
                                          getActionColor(),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      Gap(AppDimensionsTheme.getSmall(context)),
                                      Text(
                                        getActionText(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: getActionColor(),
                                          fontFamily: 'Poppins',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => handleReject(ref),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFC42121),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            minimumSize: const Size(0, 40),
                                          ),
                                          child: Text(
                                            I18nService().t('widget_phone_code.reject', fallback: 'Reject'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Gap(AppDimensionsTheme.getMedium(context)),
                                      Expanded(
                                        child: Consumer(
                                          builder: (context, ref, child) {
                                            final encryptedPhoneNumberAsync = ref.watch(getEncryptedPhoneNumberProvider);

                                            return ElevatedButton(
                                              onPressed: encryptedPhoneNumberAsync.when(
                                                data: (encryptedPhoneNumber) => encryptedPhoneNumber != null ? () => _handleConfirmWithDecryption(ref, encryptedPhoneNumber, context) : null,
                                                loading: () => null,
                                                error: (_, __) => null,
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF0E5D4A),
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                minimumSize: const Size(0, 40),
                                              ),
                                              child: encryptedPhoneNumberAsync.when(
                                                data: (encryptedPhoneNumber) => Text(
                                                  I18nService().t('widget_phone_code.confirm', fallback: 'Confirm'),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                loading: () => const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                ),
                                                error: (_, __) => Text(
                                                  I18nService().t('widget_phone_code.error', fallback: 'Error'),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
// Her til
                    Gap(AppDimensionsTheme.getLarge(context)),

                    // Contact information
                    if (widget.initiatorCompany != null) ...[
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
                            Text(
                              widget.initiatorCompany!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF014459),
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (widget.initiatorPhone != null) ...[
                              Row(
                                children: [
                                  Text(
                                    I18nService().t('widget_phone_code.phone_label', fallback: 'Phone: '),
                                    style: const TextStyle(
                                      color: Color(0xFF014459),
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    widget.initiatorPhone!,
                                    style: const TextStyle(
                                      color: Color(0xFF014459),
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              Gap(AppDimensionsTheme.getSmall(context)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Created: 2025-01-29 12:15:00
// Updated: 2025-01-29 16:30:00 - Removed properties: initiatorAddress, confirmCode, lastControlDateAt, websiteUrl, logoPath, demo
// Updated: 2025-01-29 16:30:00 - Removed _launchWebsite function and calls to it
// Updated: 2025-01-29 16:30:00 - Added deprecated getters for abstract properties compatibility
