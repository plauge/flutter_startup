import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../exports.dart';

enum ViewType { Phone, Text }

class PhoneCallWidget extends ConsumerStatefulWidget {
  final String initiatorName;
  final String? initiatorCompany;
  final String confirmCode;
  final DateTime createdAt;
  final DateTime lastControlDateAt;
  final String? initiatorPhone;
  final String? initiatorEmail;
  final String? websiteUrl;
  final Map<String, dynamic>? initiatorAddress;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final bool history;
  final int action;
  final String? phoneCodesId;
  final String? logoPath;
  final ViewType viewType;
  final bool demo;

  const PhoneCallWidget({
    super.key,
    required this.initiatorName,
    this.initiatorCompany,
    required this.confirmCode,
    required this.createdAt,
    required this.lastControlDateAt,
    this.initiatorPhone,
    this.initiatorEmail,
    this.websiteUrl,
    this.initiatorAddress,
    this.onConfirm,
    this.onReject,
    this.history = false,
    this.action = 0,
    this.phoneCodesId,
    this.logoPath,
    required this.viewType,
    this.demo = false,
  });

  @override
  ConsumerState<PhoneCallWidget> createState() => _PhoneCallWidgetState();
}

class _PhoneCallWidgetState extends ConsumerState<PhoneCallWidget> {
  static final log = scopedLogger(LogCategory.gui);
  Timer? _timer;
  late ValueNotifier<String> _timeAgoNotifier;

  // Display backend UTC times in user's local timezone
  DateTime get _createdAtLocal => widget.createdAt.toLocal();
  DateTime get _lastControlledLocal => widget.lastControlDateAt.toLocal();

  // Helper methods for action values
  bool get _isConfirmed => widget.action == 1;

  String _getActionIcon() {
    switch (widget.action) {
      case 1: // confirmed
        return 'assets/icons/phone/check_circle.svg';
      case -1: // rejected
      case -10: // timeout
      case -9: // cancelled
        return 'assets/icons/phone/cancel_circle.svg';
      default:
        return 'assets/icons/phone/cancel_circle.svg';
    }
  }

  Color _getActionColor() {
    switch (widget.action) {
      case 1: // confirmed
        return const Color(0xFF0E5D4A);
      case -1: // rejected
      case -10: // timeout
      case -9: // cancelled
        return const Color(0xFFC42121);
      default:
        return const Color(0xFFC42121);
    }
  }

  String _getActionText() {
    switch (widget.action) {
      case 1: // confirmed
        return I18nService().t('widget_phone_code.confirmed', fallback: 'Confirmed');
      case -1: // rejected
        return I18nService().t('widget_phone_code.cancelled', fallback: 'Rejected');
      case -10: // timeout
        return I18nService().t('widget_phone_code.timeout', fallback: 'Timeout');
      case -9: // cancelled
        return I18nService().t('widget_phone_code.cancelled', fallback: 'Cancelled');
      default:
        return I18nService().t('widget_phone_code.cancelled', fallback: 'Rejected');
    }
  }

  void _trackEvent(WidgetRef ref, String eventName, Map<String, dynamic> properties) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track(eventName, {
      ...properties,
      'widget': 'phone_call_widget',
      'phone_codes_id': widget.phoneCodesId ?? 'unknown',
      'view_type': widget.viewType.toString(),
      'history': widget.history,
      'demo': widget.demo,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

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

  void _handleConfirm(WidgetRef ref) {
    log('PhoneCallWidget._handleConfirm - Bekræfter telefon kode${widget.demo ? ' (demo mode)' : ''}');
    _trackEvent(ref, 'phone_call_widget_confirm_pressed', {
      'initiator_name': widget.initiatorName,
      'initiator_company': widget.initiatorCompany ?? 'unknown',
    });
    if (!widget.demo) {
      _markAsRead();
    }
    widget.onConfirm?.call();
  }

  void _handleReject(WidgetRef ref) {
    log('PhoneCallWidget._handleReject - Afviser telefon kode${widget.demo ? ' (demo mode)' : ''}');
    _trackEvent(ref, 'phone_call_widget_reject_pressed', {
      'initiator_name': widget.initiatorName,
      'initiator_company': widget.initiatorCompany ?? 'unknown',
    });
    if (!widget.demo) {
      _markAsRejected();
    }
    widget.onReject?.call();
  }

  Future<void> _launchWebsite(WidgetRef ref) async {
    if (widget.websiteUrl == null || widget.websiteUrl!.trim().isEmpty) {
      log('PhoneCallWidget._launchWebsite - Ingen eller tom websiteUrl');
      return;
    }

    log('PhoneCallWidget._launchWebsite - websiteUrl: "${widget.websiteUrl}"');
    _trackEvent(ref, 'phone_call_widget_website_clicked', {
      'website_url': widget.websiteUrl!.trim(),
      'initiator_name': widget.initiatorName,
    });

    try {
      String url = widget.websiteUrl!.trim();
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }

      log('PhoneCallWidget._launchWebsite - Åbner: $url');

      final Uri uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      log('PhoneCallWidget._launchWebsite - Fejl: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // Track widget view
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _trackEvent(ref, 'phone_call_widget_viewed', {
            'initiator_name': widget.initiatorName,
            'initiator_company': widget.initiatorCompany ?? 'unknown',
            'action': widget.action,
            'is_confirmed': _isConfirmed,
          });
        });

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            children: [
              // Header with timer
              if (widget.demo) ...[
                CustomHelpText(
                  text: I18nService().t('widget_phone_code.debug_help_text', fallback: 'Here’s an example of what it looks like when a company calls you.'),
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
              ],
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
                            '${_createdAtLocal.day.toString().padLeft(2, '0')}.${_createdAtLocal.month.toString().padLeft(2, '0')}.${_createdAtLocal.year} ${_createdAtLocal.hour.toString().padLeft(2, '0')}:${_createdAtLocal.minute.toString().padLeft(2, '0')}',
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
                      GestureDetector(
                        onTap: widget.websiteUrl != null && widget.websiteUrl!.trim().isNotEmpty ? () => _launchWebsite(ref) : null,
                        behavior: HitTestBehavior.opaque,
                        child: Image.network(
                          widget.logoPath!,
                          width: 200,
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
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
                            // Instruction text
                            // Text(
                            //   I18nService().t('widget_phone_code.get_person_to_say_code', fallback: 'Get ${widget.initiatorName} to say this code:', variables: {'name': widget.initiatorName}),
                            //   textAlign: TextAlign.center,
                            //   style: const TextStyle(
                            //     color: Color(0xFF014459),
                            //     fontFamily: 'Poppins',
                            //     fontSize: 12,
                            //     fontWeight: FontWeight.w400,
                            //     height: 1.15,
                            //   ),
                            // ),

                            // Gap(AppDimensionsTheme.getLarge(context)),

                            // // Code display
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: _buildCodeDigits(),
                            // ),

                            //Gap(AppDimensionsTheme.getLarge(context)),

// Action buttons or confirmed status
                            widget.history
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        _getActionIcon(),
                                        width: 30,
                                        height: 30,
                                        colorFilter: ColorFilter.mode(
                                          _getActionColor(),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      Gap(AppDimensionsTheme.getSmall(context)),
                                      Text(
                                        _getActionText(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _getActionColor(),
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
                                          onPressed: () => _handleReject(ref),
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
                                          onPressed: () => _handleConfirm(ref),
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
                    if (_getFormattedAddress() != null || widget.initiatorPhone != null || widget.initiatorEmail != null || (widget.websiteUrl != null && widget.websiteUrl!.trim().isNotEmpty)) ...[
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
                              Gap(AppDimensionsTheme.getSmall(context)),
                            ],
                            if (widget.websiteUrl != null && widget.websiteUrl!.trim().isNotEmpty) ...[
                              GestureDetector(
                                onTap: () => _launchWebsite(ref),
                                behavior: HitTestBehavior.opaque,
                                child: Text(
                                  I18nService().t('widget_phone_code.visit_website', fallback: 'Visit website'),
                                  style: const TextStyle(
                                    color: Color(0xFF418BA2),
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
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
                          'day': _lastControlledLocal.day.toString().padLeft(2, '0'),
                          'month': _lastControlledLocal.month.toString().padLeft(2, '0'),
                          'year': _lastControlledLocal.year.toString(),
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
      },
    );
  }
}

// Created: 2025-01-26 17:30:00
