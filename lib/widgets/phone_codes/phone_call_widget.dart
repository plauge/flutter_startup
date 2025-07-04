import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import '../../exports.dart';

class PhoneCallWidget extends ConsumerStatefulWidget {
  final String initiatorName;
  final String? initiatorCompany;
  final String confirmCode;
  final DateTime createdAt;
  final DateTime lastControlDateAt;
  final String? initiatorPhone;
  final String? initiatorEmail;
  final Map<String, dynamic>? initiatorAddress;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final bool history;
  final bool isConfirmed;
  final String? phoneCodesId;
  final String? logoPath;

  const PhoneCallWidget({
    super.key,
    required this.initiatorName,
    this.initiatorCompany,
    required this.confirmCode,
    required this.createdAt,
    required this.lastControlDateAt,
    this.initiatorPhone,
    this.initiatorEmail,
    this.initiatorAddress,
    this.onConfirm,
    this.onReject,
    this.history = false,
    this.isConfirmed = false,
    this.phoneCodesId,
    this.logoPath,
  });

  @override
  ConsumerState<PhoneCallWidget> createState() => _PhoneCallWidgetState();
}

class _PhoneCallWidgetState extends ConsumerState<PhoneCallWidget> {
  static final log = scopedLogger(LogCategory.gui);
  Timer? _timer;
  late ValueNotifier<String> _timeAgoNotifier;

  @override
  void initState() {
    super.initState();
    _timeAgoNotifier = ValueNotifier(_getTimeAgo());

    // Start timer der opdaterer kun timer teksten hvert sekund
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeAgoNotifier.value = _getTimeAgo();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeAgoNotifier.dispose();
    super.dispose();
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(widget.createdAt);
    final totalSeconds = difference.inSeconds;

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return 'Aktiv: ${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String? _getFormattedAddress() {
    if (widget.initiatorAddress == null) return null;

    final address = widget.initiatorAddress!;
    final addressParts = <String>[];

    if (address['street'] != null && address['street'].toString().isNotEmpty) {
      addressParts.add(address['street'].toString());
    }
    if (address['postal_code'] != null && address['postal_code'].toString().isNotEmpty) {
      addressParts.add(address['postal_code'].toString());
    }
    if (address['city'] != null && address['city'].toString().isNotEmpty) {
      addressParts.add(address['city'].toString());
    }
    if (address['region'] != null && address['region'].toString().isNotEmpty) {
      addressParts.add(address['region'].toString());
    }
    if (address['country'] != null && address['country'].toString().isNotEmpty) {
      addressParts.add(address['country'].toString());
    }

    return addressParts.isEmpty ? null : addressParts.join('\n');
  }

  List<Widget> _buildCodeDigits() {
    final digits = widget.confirmCode.split('');
    return digits
        .map((digit) => Container(
              width: 32,
              height: 44,
              margin: EdgeInsets.symmetric(horizontal: AppDimensionsTheme.getSmall(context)),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  digit,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF014459),
                    fontFamily: 'Poppins',
                    fontSize: 17.6,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ))
        .toList();
  }

  Future<void> _markAsRead() async {
    if (widget.phoneCodesId != null) {
      try {
        await ref.read(markPhoneCodeAsReadProvider(widget.phoneCodesId!).future);
        log('PhoneCallWidget._markAsRead - Markeret som læst: ${widget.phoneCodesId}');
      } catch (e) {
        log('PhoneCallWidget._markAsRead - Fejl ved markering som læst: $e');
        // Error handling is done in provider
      }
    }
  }

  Future<void> _markAsRejected() async {
    if (widget.phoneCodesId != null) {
      try {
        await ref.read(markPhoneCodeAsRejectedProvider(widget.phoneCodesId!).future);
        log('PhoneCallWidget._markAsRejected - Markeret som afvist: ${widget.phoneCodesId}');
      } catch (e) {
        log('PhoneCallWidget._markAsRejected - Fejl ved markering som afvist: $e');
        // Error handling is done in provider
      }
    }
  }

  void _handleConfirm() {
    log('PhoneCallWidget._handleConfirm - Bekræfter telefon kode');
    _markAsRead();
    widget.onConfirm?.call();
  }

  void _handleReject() {
    log('PhoneCallWidget._handleReject - Afviser telefon kode');
    _markAsRejected();
    widget.onReject?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: [
          // Header with timer
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
                        '${widget.createdAt.day.toString().padLeft(2, '0')}.${widget.createdAt.month.toString().padLeft(2, '0')}.${widget.createdAt.year} ${widget.createdAt.hour.toString().padLeft(2, '0')}:${widget.createdAt.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 22 / 12, // 22px line-height / 12px font-size = 1.833
                        ),
                      )
                    : ValueListenableBuilder<String>(
                        valueListenable: _timeAgoNotifier,
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
                // Logo (kun hvis logo_path findes)
                if (widget.logoPath != null && widget.logoPath!.isNotEmpty)
                  Image.network(
                    widget.logoPath!,
                    width: 200,
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),

                Gap(AppDimensionsTheme.getMedium(context)),

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

                // // Company (if provided)
                // if (widget.initiatorCompany != null) ...[
                //   Gap(AppDimensionsTheme.getSmall(context)),
                //   Text(
                //     widget.initiatorCompany!,
                //     textAlign: TextAlign.center,
                //     style: const TextStyle(
                //       color: Color(0xFF014459),
                //       fontFamily: 'Poppins',
                //       fontSize: 16,
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                // ],

                Gap(AppDimensionsTheme.getLarge(context)),

// Herfra
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Instruction text
                      Text(
                        I18nService().t('widget_phone_code.get_person_to_say_code', fallback: 'Get ${widget.initiatorName} to say this code:', variables: {'name': widget.initiatorName}),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF014459),
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.15,
                        ),
                      ),

                      Gap(AppDimensionsTheme.getLarge(context)),

                      // Code display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildCodeDigits(),
                      ),

                      Gap(AppDimensionsTheme.getLarge(context)),

// Action buttons or confirmed status
                      widget.history
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  widget.isConfirmed ? 'assets/icons/phone/check_circle.svg' : 'assets/icons/phone/cancel_circle.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                    widget.isConfirmed ? const Color(0xFF0E5D4A) : const Color(0xFFC42121),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                Gap(AppDimensionsTheme.getSmall(context)),
                                Text(
                                  widget.isConfirmed ? I18nService().t('widget_phone_code.confirmed', fallback: 'Bekræftet') : I18nService().t('widget_phone_code.cancelled', fallback: 'Afvist'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: widget.isConfirmed ? const Color(0xFF0E5D4A) : const Color(0xFFC42121),
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _handleReject,
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
                                  child: ElevatedButton(
                                    onPressed: _handleConfirm,
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
                                    child: Text(
                                      I18nService().t('widget_phone_code.confirm', fallback: 'Confirm'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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
                if (_getFormattedAddress() != null || widget.initiatorPhone != null || widget.initiatorEmail != null) ...[
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
                        if (_getFormattedAddress() != null) ...[
                          Text(
                            _getFormattedAddress()!,
                            style: const TextStyle(
                              color: Color(0xFF014459),
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Gap(AppDimensionsTheme.getLarge(context)),
                        ],
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
                        if (widget.initiatorEmail != null) ...[
                          Row(
                            children: [
                              Text(
                                I18nService().t('widget_phone_code.email_label', fallback: 'E-mail: '),
                                style: const TextStyle(
                                  color: Color(0xFF014459),
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.initiatorEmail!,
                                style: const TextStyle(
                                  color: Color(0xFF014459),
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                Gap(AppDimensionsTheme.getMedium(context)),

                // Last controlled date
                Text(
                  I18nService().t(
                    'widget_phone_code.last_controlled',
                    fallback: 'Sidst kontrolleret: {day}.{month}.{year}',
                    variables: {
                      'day': widget.lastControlDateAt.day.toString().padLeft(2, '0'),
                      'month': widget.lastControlDateAt.month.toString().padLeft(2, '0'),
                      'year': widget.lastControlDateAt.year.toString(),
                    },
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF014459),
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 22 / 12, // 22px line-height / 12px font-size = 1.833
                  ),
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
